require 'gds_api/gov_uk_delivery'
require 'plek'

Whitehall.govuk_delivery_client = GdsApi::GovUkDelivery.new(Plek.current.find('govuk-delivery'))
