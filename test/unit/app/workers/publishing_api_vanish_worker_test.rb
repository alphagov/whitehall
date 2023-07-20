require "test_helper"
require "gds_api/test_helpers/publishing_api"

class PublishingApiVanishWorkerTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::PublishingApi

  test "publishes a 'vanish' item for the supplied content id" do
    publication = create(:withdrawn_publication)

    request = stub_publishing_api_unpublish(
      publication.content_id,
      body: {
        type: "vanish",
        locale: "en",
      },
    )

    PublishingApiVanishWorker.perform_async(publication.content_id, "en")
    PublishingApiVanishWorker.drain

    assert_requested request
  end

  test "publishes a 'vanish' item for the supplied content id including the discard drafts flag" do
    publication = create(:withdrawn_publication)

    request = stub_publishing_api_unpublish(
      publication.content_id,
      body: {
        type: "vanish",
        locale: "en",
        discard_drafts: true,
      },
    )

    PublishingApiVanishWorker.perform_async(publication.content_id, "en", true)
    PublishingApiVanishWorker.drain

    assert_requested request
  end
end
