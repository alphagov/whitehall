require "test_helper"
require "gds_api/test_helpers/publishing_api_v2"

class PublishingApiVanishWorkerTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::PublishingApi

  test "publishes a 'vanish' item for the supplied content id" do
    publication = create(:withdrawn_publication)

    request = stub_publishing_api_unpublish(
      publication.document.content_id,
      body: {
        type: "vanish",
        locale: "en",
      },
    )

    PublishingApiVanishWorker.new.perform(
      publication.document.content_id, "en"
    )

    assert_requested request
  end

  test "publishes a 'vanish' item for the supplied content id including the discard drafts flag" do
    publication = create(:withdrawn_publication)

    request = stub_publishing_api_unpublish(
      publication.document.content_id,
      body: {
        type: "vanish",
        locale: "en",
        discard_drafts: true,
      },
    )

    PublishingApiVanishWorker.new.perform(
      publication.document.content_id, "en", discard_drafts: true
    )

    assert_requested request
  end

  test "an error if document is locked" do
    document = create(:document, locked: true)

    assert_raises LockedDocumentConcern::LockedDocumentError, "Cannot perform this operation on a locked document" do
      PublishingApiVanishWorker.new.perform(document.content_id, "en")
    end
  end
end
