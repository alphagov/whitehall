require 'test_helper'
require 'gds_api/test_helpers/publishing_api'

class PublishingApiWorkerTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::PublishingApi

  test "registers a draft edition with the publishing api" do
    edition   = create(:draft_case_study)
    presenter = PublishingApiPresenters.presenter_for(edition)
    request   = stub_publishing_api_put_draft_item(presenter.base_path, presenter.as_json)

    PublishingApiDraftWorker.new.perform(edition.class.name, edition.id)

    assert_requested request
  end
end
