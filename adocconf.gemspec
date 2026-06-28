require_relative "lib/adocconf/version"

Gem::Specification.new do |s|
  s.name = "adocconf"
  s.version = Adocconf::VERSION
  s.authors = ["Nathan Hammer"]
  s.summary = "Create configuration using AsciiDoc"
  s.description = "adocconf allows you to create both configuration using AsciiDoc."
  s.required_ruby_version = ">= 3.1"
  s.homepage = "https://github.com/vphammer/adocconf"
  s.license = "MIT"

  s.files = Dir[
    "LICENSE",
    "exe/*",
    "lib/**/*.rb",
  ]
  s.bindir = "exe"
  s.executables = ["adocconf"]
  s.require_paths = ["lib"]

  s.add_dependency "asciidoctor"
  s.add_development_dependency "rspec"
end
