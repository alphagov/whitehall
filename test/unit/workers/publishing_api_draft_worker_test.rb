require 'test_helper'
require 'gds_api/test_helpers/publishing_api_v2'

class PublishingApiDraftWorkerTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::PublishingApiV2

  test "registers a draft edition with the publishing api" do
    edition = create(:draft_case_study)
    presenter = PublishingApiPresenters.presenter_for(edition)

    requests = [
      stub_publishing_api_put_content(presenter.content_id, presenter.content),
    ]

    PublishingApiDraftWorker.new.perform(edition.class.name, edition.id)

    assert_all_requested requests
  end
end
