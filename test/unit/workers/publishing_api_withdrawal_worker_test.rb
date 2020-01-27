require "test_helper"
require "gds_api/test_helpers/publishing_api_v2"

class PublishingApiWithdrawalWorkerTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::PublishingApi

  test "publishes a 'withdrawal' item for the supplied content id" do
    publication = create(:withdrawn_publication)

    request = stub_publishing_api_unpublish(
      publication.document.content_id,
      body: {
        type: "withdrawal",
        locale: "en",
        explanation: "<div class=\"govspeak\"><p><em>why?</em></p>\n</div>",
        unpublished_at: publication.updated_at.utc.iso8601,
      },
    )

    PublishingApiWithdrawalWorker.new.perform(
      publication.document.content_id, "*why?*", "en"
    )

    assert_requested request
  end

  test "raises an error if the document is locked" do
    document = create(:document, locked: true)

    assert_raises LockedDocumentConcern::LockedDocumentError, "Cannot perform this operation on a locked document" do
      PublishingApiWithdrawalWorker.new.perform(
        document.content_id, "*why?*", "en"
      )
    end
  end
end
