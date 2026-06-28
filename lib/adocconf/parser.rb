module Adocconf
  class Parser
    def parse_file(path)
      raise ParseError, "File not found: #{path}" unless File.file?(path)

      doc = Asciidoctor.load_file(path, safe: :safe, parse: true)
      Extractor.new(doc).extract
    rescue Adocconf::Error
      raise
    rescue StandardError => e
      raise ParseError, e.message
    end
  end
end
