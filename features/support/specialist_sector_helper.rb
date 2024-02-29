require "gds_api/test_helpers/content_store"

Before do
  stub_request(:get, %r{.*content-store.*/content/.*}).to_return(status: 404)
  stub_publishing_api_has_linkables([], document_type: "topic")
end

module SpecialistSectorHelper
  include GdsApi::TestHelpers::ContentStore
end

World(SpecialistSectorHelper)
