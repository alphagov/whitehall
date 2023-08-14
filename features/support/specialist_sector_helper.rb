require "gds_api/test_helpers/content_store"

Before do
  stub_request(:get, %r{.*content-store.*/content/.*}).to_return(status: 404)
  stub_publishing_api_has_linkables([], document_type: "topic")
end

module SpecialistSectorHelper
  include GdsApi::TestHelpers::ContentStore

  def stub_specialist_sectors
    stub_publishing_api_has_linkables(
      [
        {
          "content_id" => "WELLS",
          "internal_name" => "Oil and Gas / Wells",
          "publication_state" => "published",
        },
        {
          "content_id" => "FIELDS",
          "internal_name" => "Oil and Gas / Fields",
          "publication_state" => "published",
        },
        {
          "content_id" => "OFFSHORE",
          "internal_name" => "Oil and Gas / Offshore",
          "publication_state" => "published",
        },
        {
          "content_id" => "DISTILL",
          "internal_name" => "Oil and Gas / Distillation",
          "publication_state" => "draft",
        },
      ],
      document_type: "topic",
    )
  end
end

World(SpecialistSectorHelper)
