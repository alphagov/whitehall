require "test_helper"
require "gds_api/test_helpers/publishing_api_v2"

class PublishingApiWithdrawalWorkerTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::PublishingApiV2

  test "publishes a 'withdrawal' item for the supplied content id" do
    publication = create(:withdrawn_publication)

    request = stub_publishing_api_unpublish(
      publication.document.content_id,
      body: {
        type: "withdrawal",
        locale: "en",
        explanation: "<div class=\"govspeak\"><p><em>why?</em></p>\n</div>",
        unpublished_at: publication.updated_at.utc.iso8601
      }
    )

    PublishingApiWithdrawalWorker.new.perform(
      publication.document.content_id, "*why?*", "en"
    )

    assert_requested request
  end
end
