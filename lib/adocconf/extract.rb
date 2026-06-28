module Adocconf
  class Extractor
    def initialize(document)
      @document = document
    end

    def extract
      extract_node(@document)
    end

    def extract_node(node)
      sections = child_sections(node)

      if sections.any?
        extract_container(node, sections)
      else
        extract_value_section(node)
      end
    end

    def child_sections(node)
      return [] unless node.respond_to?(:blocks)
      node.blocks.select { |block| block.context == :section }
    end

    def non_section_blocks(node)
      return [] unless node.respond_to?(:blocks)
      node.blocks.reject { |block| block.context == :section }
    end

    def extract_container(_node, sections)
      result = {}

      sections.each do |section|
        key = slugify(section.title)

        if result.key?(key)
          raise DuplicateKeyError, "Duplicate section key: #{key}"
        end

        result[key] = extract_node(section)
      end

      result
    end

    def extract_term_text(term)
      if term.respond_to?(:text)
        term.text.to_s
      else
        term.to_s
      end
    end

    def extract_description_text(description)
      if description.respond_to?(:text)
        description.text.to_s.strip
      elsif description.respond_to?(:blocks) && description.blocks&.any?
        raise UnsupportedNodeError, "Complex description list values are not supported"
      else
        ""
      end
    end

    def extract_value_section(node)
      blocks = non_section_blocks(node)
      values = []

      blocks.each do |block|
        case block.context
        when :dlist
          values << extract_dlist(block)
        when :ulist
          values << extract_ulist(block)
        when :table
          values << extract_table(block)
        when :paragraph
          # ignored by spec
        when :open, :example, :listing, :literal, :quote, :verse, :stem, :sidebar, :image, :audio, :video
          handle_unsupported(block)
        else
          handle_unsupported(block)
        end
      end

      merge_values(values)
    end

    def extract_dlist(block)
      result = {}

      block.items.each do |terms, description|
        if terms.nil? || terms.empty?
          raise InvalidStructureError, "Description list item is missing a term"
        end

        key = extract_term_text(terms.first).strip

        if result.key?(key)
          raise DuplicateKeyError, "Duplicate key in description list: #{key}"
        end

        result[key] = extract_description_text(description)
      end

      result
    end

    def extract_dlist_term(item)
      terms = item.respond_to?(:terms) ? item.terms : []
      raise InvalidStructureError, "Description list item is missing a term" if terms.nil? || terms.empty?

      term = terms.first
      term.respond_to?(:text) ? term.text : term.to_s
    end

    def extract_dlist_value(item)
      return item.text.strip if item.respond_to?(:text) && item.text

      raise UnsupportedNodeError, "Complex description list values are not supported" if item.respond_to?(:blocks) && item.blocks&.any?

      ""
    end

    def extract_ulist(block)
      block.items.map do |item|
        nested_blocks = item.respond_to?(:blocks) ? item.blocks : []
        nested_lists = nested_blocks.select { |b| b.context == :ulist || b.context == :olist }

        if nested_lists.any?
          raise UnsupportedNodeError, "Nested lists are not supported"
        end

        item.text.to_s.strip
      end
    end

    def extract_table(block)
      head_rows = block.rows[:head] || []
      body_rows = block.rows[:body] || []

      raise InvalidStructureError, "Table must have a header row" if head_rows.empty?

      headers = head_rows.first.map { |cell| cell.text.to_s.strip }
      raise InvalidStructureError, "Table header cannot be empty" if headers.empty?

      body_rows.map do |row|
        if row.length != headers.length
          raise InvalidStructureError,
                "Table row width mismatch: expected #{headers.length}, got #{row.length}"
        end

        result = {}
        headers.zip(row).each do |header, cell|
          result[header] = cell.text.to_s.strip
        end
        result
      end
    end

    def merge_values(values)
      return {} if values.empty?
      return values.first if values.length == 1

      if values.all? { |value| value.is_a?(Hash) }
        merged = {}

        values.each do |hash|
          hash.each do |key, value|
          if merged.key?(key)
            raise DuplicateKeyError, "Duplicate merged key: #{key}"
          end

          merged[key] = value
        end
      end

        return merged
      end

      if values.all? { |value| value.is_a?(Array) }
        return values.flatten(1)
      end

      raise InvalidStructureError, "Mixed value types in section are not supported"
    end

    def slugify(title)
      value = Slugifier.call(title)
      raise InvalidStructureError, "Section title produced an empty slug" if value.empty?

      value
    end

    def handle_unsupported(block)
      raise UnsupportedNodeError, "Unsupported block context: #{block.context}"
    end
  end
end
