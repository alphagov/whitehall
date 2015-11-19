require 'test_helper'
require 'gds_api/test_helpers/publishing_api_v2'

class PublishingApiWorkerTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::PublishingApiV2

  test "registers a draft edition with the publishing api" do
    edition         = create(:draft_case_study)
    presenter       = PublishingApiPresenters.presenter_for(edition)
    content_request = stub_publishing_api_put_content(presenter.as_json[:content_id], presenter.as_json.except(:links))
    links_request   = stub_publishing_api_put_links(presenter.as_json[:content_id], presenter.as_json.slice(:links))

    PublishingApiDraftWorker.new.perform(edition.class.name, edition.id)

    assert_requested content_request
    assert_requested links_request
  end
end
