require 'test_helper'
require 'gds_api/test_helpers/publishing_api'

class PublishingApiRegisterOrganisationWorkerTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::PublishingApi

  test "registers an organisagtion with the publishing api" do
    organisation = create(:organisation)
    stub_publishing_api_put_item(organisation.base_path, organisation.attributes_for_publishing_api)

    PublishingApiRegisterOrganisationWorker.new.perform(organisation.id)

    assert_publishing_api_put_item(organisation.base_path,
      JSON.parse(organisation.attributes_for_publishing_api.to_json))
  end
end
