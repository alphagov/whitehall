require 'test_helper'
require 'gds_api/test_helpers/publishing_api_v2'

class PublishingApDiscardDraftiWorkerTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::PublishingApiV2

  test "registers a draft edition with the publishing api" do
    edition = create(:draft_case_study)
    request = stub_publishing_api_discard_draft(edition.content_id)

    PublishingApiDiscardDraftWorker.new.perform(edition.content_id, 'en')

    assert_requested request
  end
end
