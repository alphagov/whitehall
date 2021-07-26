require "gds_api/test_helpers/content_store"

Before do
  # FIXME: This stubs out calls to the content store, returning an empty
  # response. Calls to this endpoint are only needed in SpecialistTagFinder,
  # for rendering the header in Whitehall frontend. Ideally this should be
  # replaced by explicit stubs in every feature that renders a frontend page.
  # That's a fairly large reworking of the tests, however, and those pages are
  # in the process of being migrated to government-frontend. For now then, this
  # stub should be overriden in specific features where this behaviour needs to
  # be tested.
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
