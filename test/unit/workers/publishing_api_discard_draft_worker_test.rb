require 'test_helper'
require 'gds_api/test_helpers/publishing_api_v2'

class PublishingApiDiscardDraftWorkerTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::PublishingApiV2

  def setup
    @edition = create(:draft_case_study)
    WebMock.reset!
  end

  test "registers a draft edition with the publishing api" do
    request = stub_publishing_api_discard_draft(@edition.content_id)

    PublishingApiDiscardDraftWorker.new.perform(@edition.content_id, 'en')

    assert_requested request
  end

  test "gracefully handles the deletion of an already-deleted draft edition" do
    request = stub_any_publishing_api_call
      .to_return(status: 422)

    PublishingApiDiscardDraftWorker.new.perform(@edition.content_id, 'en')

    assert_requested request
  end

  test "gracefully handles the deletion of a non-existant content item" do
    request = stub_any_publishing_api_call_to_return_not_found

    PublishingApiDiscardDraftWorker.new.perform(@edition.content_id, 'en')

    assert_requested request
  end

  test "raises an error if an edition's document is locked" do
    document = build(:document, locked: true)
    edition = create(:published_edition, document: document)

    assert_raises LockedDocumentConcern::LockedDocumentError, "Cannot perform this operation on a locked document" do
      PublishingApiDiscardDraftWorker.new.perform(edition.content_id, "en")
    end
  end
end
