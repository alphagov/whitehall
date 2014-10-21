require 'test_helper'
require 'gds_api/test_helpers/publishing_api'

class PublishingApiRegisterOrganisationWorkerTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::PublishingApi

  test "sends an organisation to the publishing api" do
    organisation = create(:organisation)
    presenter = PublishingApiPresenters::Organisation.new(organisation)

    assert_publishing_api_put_item(
      presenter.base_path,
      JSON.parse(presenter.as_json.to_json)
    )
  end
end
