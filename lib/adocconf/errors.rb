module Adocconf
    class Error < StandardError; end
    class DuplicateKeyError < Error; end
    class InvalidStructureError < Error; end
    class UnsupportedNodeError < Error; end
    class ParseError < Error; end
end