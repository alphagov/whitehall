require 'gds_api/gov_uk_delivery'
require 'plek'

unless ENV['USE_GOVUK_DELIVERY']
  Whitehall.govuk_delivery_client = GdsApi::GovUkDelivery.new(Plek.current.find('govuk-delivery'), {noop: true})
else
  Whitehall.govuk_delivery_client = GdsApi::GovUkDelivery.new(Plek.current.find('govuk-delivery'))
end
