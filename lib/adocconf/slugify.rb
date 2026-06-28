module Adocconf
    module Slugifier
        module_function
        def call(value)
            value.to_s
                 .downcase
                 .strip
                 .gsub(/[^a-z0-9]+/, "_")
                 .gsub(/-+/, "_")
                 .gsub(/\A-+|-+\z/, "")
        end
    end
end