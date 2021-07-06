require "pact/provider/rspec"
require "webmock/rspec"
require "factory_bot"
require "database_cleaner"

require ::File.expand_path("../../config/environment", __dir__)

Dir[Rails.root.join("test/factories/*.rb")].sort.each { |f| require f }

Pact.configure do |config|
  config.reports_dir = "spec/reports/pacts"
  config.include WebMock::API
  config.include WebMock::Matchers
  config.include FactoryBot::Syntax::Methods
end

WebMock.allow_net_connect!

def url_encode(str)
  ERB::Util.url_encode(str)
end

Pact.service_provider "Whitehall" do
  honours_pact_with "GDS API Adapters" do
    if ENV["PACT_URI"]
      pact_uri(ENV["PACT_URI"])
    else
      base_url = "https://pact-broker.cloudapps.digital"
      path = "pacts/provider/#{url_encode(name)}/consumer/#{url_encode(consumer_name)}"
      version_modifier = "versions/#{url_encode(ENV.fetch('PACT_CONSUMER_VERSION', 'branch-whitehall-api-pact-tests'))}"

      pact_uri("#{base_url}/#{path}/#{version_modifier}")
    end
  end
end
