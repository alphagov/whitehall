require 'gds_api/gov_uk_delivery'
require 'plek'

unless Rails.env.production? || ENV['USE_GOVUK_DELIVERY']
  options = {
    noop: true,
    stdout: Rails.env.development?
  }
  Whitehall.govuk_delivery_client = GdsApi::GovUkDelivery.new(Plek.find('govuk-delivery'), options)
else
  Whitehall.govuk_delivery_client = GdsApi::GovUkDelivery.new(Plek.find('govuk-delivery'))
end
