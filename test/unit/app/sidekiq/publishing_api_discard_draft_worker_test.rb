require "test_helper"
require "gds_api/test_helpers/publishing_api"

class PublishingApiDiscardDraftWorkerTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::PublishingApi

  def setup
    @edition = create(:draft_case_study)
    WebMock.reset!
  end

  test "registers a draft edition with the publishing api" do
    request = stub_publishing_api_discard_draft(@edition.content_id)

    PublishingApiDiscardDraftWorker.new.perform(@edition.content_id, "en")

    assert_requested request
  end

  test "gracefully handles the deletion of an already-deleted draft edition" do
    request = stub_any_publishing_api_call
      .to_return(status: 422)

    PublishingApiDiscardDraftWorker.new.perform(@edition.content_id, "en")

    assert_requested request
  end

  test "gracefully handles the deletion of a non-existant content item" do
    request = stub_any_publishing_api_call_to_return_not_found

    PublishingApiDiscardDraftWorker.new.perform(@edition.content_id, "en")

    assert_requested request
  end
end
