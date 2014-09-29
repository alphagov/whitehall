require 'test_helper'
require 'gds_api/test_helpers/publishing_api'

class PublishingApiRegisterArtefactWorkerTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::PublishingApi

  test "registers an artefact with the publishing api" do
    edition = create(:published_detailed_guide)
    registerable_edition = RegisterableEdition.new(edition)
    stub_publishing_api_put_item(registerable_edition.base_path, registerable_edition.attributes_for_publishing_api)

    PublishingApiRegisterArtefactWorker.new.perform(edition.id)

    assert_publishing_api_put_item(registerable_edition.base_path,
      JSON.parse(registerable_edition.attributes_for_publishing_api.to_json))
  end
end
