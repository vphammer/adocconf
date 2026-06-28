module Adocconf
  class CLI
    def self.start(argv)
      command = argv.shift

      case command
      when "parse"
        parse_command(argv)
      else
        warn "Unknown command: #{command}"
        1
      end
    rescue Adocconf::Error => e
      warn "error: #{e.message}"
      1
    end

    def self.parse_command(argv)
      path = argv.shift
      raise ParseError, "No input file provided" if path.nil? || path.strip.empty?

      result = Parser.new.parse_file(path)

      puts JSON.pretty_generate(result)
      0
    end
  end
end
