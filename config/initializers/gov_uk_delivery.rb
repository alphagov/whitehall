require 'gds_api/gov_uk_delivery'
require 'plek'

unless Rails.env.production? || ENV['USE_GOVUK_DELIVERY']
  options = {
    noop: true,
    stdout: Rails.env.development?
  }
  Whitehall.govuk_delivery_client = GdsApi::GovUkDelivery.new(Plek.current.find('govuk-delivery'), options)
else
  Whitehall.govuk_delivery_client = GdsApi::GovUkDelivery.new(Plek.current.find('govuk-delivery'))
end

# Until we have this method in the API...
client = Whitehall.govuk_delivery_client
def client.new_signup_url(*args)
  'http://govdelivery.example.com/new-signup/'
end
