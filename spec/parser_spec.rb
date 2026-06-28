require "adocconf"

RSpec.describe Adocconf::Parser do
  let(:parser) { described_class.new }
  let(:path) { File.expand_path("basic.adoc", __dir__) }

  it "basic functionality test" do
    result = parser.parse_file(path)

    expect(result).to eq(
      {
        "servers" => {
          "server1" => {
            "host" => "localhost",
            "port" => "80"
          },
          "server2" => {
            "host" => "default",
            "port" => "8080"
          },
          "server3" => {
            "host" => "prod.example.com",
            "port" => "443"
          }
        },
        "features" => ["login", "signup", "analytics"],
        "other_servers" => [
          {
            "Name" => "server1",
            "Host" => "default",
            "Port" => "8080"
          },
          {
            "Name" => "server2",
            "Host" => "remote",
            "Port" => "9090"
          },
          {
            "Name" => "server3",
            "Host" => "server3.test.com",
            "Port" => "80"
          },
          {
            "Name" => "server4",
            "Host" => "server4.test.com",
            "Port" => "443"
          }
        ]
      }
    )
  end
end
