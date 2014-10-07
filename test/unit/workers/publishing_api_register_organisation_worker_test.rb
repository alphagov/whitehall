require 'test_helper'
require 'gds_api/test_helpers/publishing_api'

class PublishingApiRegisterOrganisationWorkerTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::PublishingApi

  test "sends an organisation to the publishing api" do
    organisation = create(:organisation)

    assert_publishing_api_put_item(organisation.base_path,
      JSON.parse(organisation.attributes_for_publishing_api.to_json))
  end
end
