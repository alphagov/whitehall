require "test_helper"
require "gds_api/test_helpers/publishing_api_v2"

class PublishingApiVanishWorkerTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::PublishingApiV2

  test "publishes a 'vanish' item for the supplied content id" do
    publication = create(:withdrawn_publication)

    request = stub_publishing_api_unpublish(
      publication.document.content_id,
      body: {
        type: "vanish",
        locale: "en"
      }
    )

    PublishingApiVanishWorker.new.perform(
      publication.document.content_id, "en"
    )

    assert_requested request
  end
end
