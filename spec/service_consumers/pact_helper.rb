ENV["RAILS_ENV"] = "test"

require "pact/provider/rspec"
require "webmock/rspec"
require "factory_bot"
require "database_cleaner/active_record"

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

Pact.service_provider "Whitehall API" do
  honours_pact_with "GDS API Adapters" do
    if ENV["PACT_URI"]
      pact_uri(ENV["PACT_URI"])
    else
      base_url = "https://pact-broker.cloudapps.digital"
      path = "pacts/provider/#{url_encode(name)}/consumer/#{url_encode(consumer_name)}"
      version_modifier = "versions/#{url_encode(ENV.fetch('PACT_CONSUMER_VERSION', 'branch-master'))}"

      pact_uri("#{base_url}/#{path}/#{version_modifier}")
    end
  end
end

Pact.provider_states_for "GDS API Adapters" do
  provider_state "a world location exists" do
    set_up do
      DatabaseCleaner.clean_with :truncation
      create(:world_location, name: "France", slug: "france")
    end
  end

  provider_state "a worldwide organisation exists" do
    set_up do
      DatabaseCleaner.clean_with :truncation
      stub_request(:any, %r{#{Regexp.escape(Plek.find('publishing-api'))}/v2/content})
      stub_request(:any, %r{#{Regexp.escape(Plek.find('publishing-api'))}/v2/links/})

      create(:world_location, :with_worldwide_organisations, slug: "france")
    end
  end
end
