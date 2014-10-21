require 'test_helper'
require 'gds_api/test_helpers/publishing_api'

class PublishingApiRegisterArtefactWorkerTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::PublishingApi

  test "registers an edition with the publishing api" do
    edition = create(:published_detailed_guide)
    presenter = PublishingApiPresenters::Edition.new(edition)
    stub_publishing_api_put_item(presenter.base_path, presenter.as_json)

    PublishingApiRegisterArtefactWorker.new.perform(edition.id)

    assert_publishing_api_put_item(presenter.base_path,
      JSON.parse(presenter.as_json.to_json))
  end
end
