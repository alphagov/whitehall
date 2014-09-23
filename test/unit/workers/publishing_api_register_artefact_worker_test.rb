require 'test_helper'
require 'gds_api/test_helpers/publishing_api'

class PublishingApiRegisterArtefactWorkerTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::PublishingApi

  test "registers an artefact with the publishing api" do
    edition = create(:published_detailed_guide)
    base_path = "/government/publications/#{edition.slug}"

    fake_registerable_edition = mock
    fake_registerable_edition.stubs(:base_path).returns(base_path)
    fake_registerable_edition.stubs(:attributes_for_publishing_api).returns(fake_attributes_for_publishing_api)

    fake_attributes_for_publishing_api = { fake_attribute: 'fake-value' }
    stub_publishing_api_put_item(base_path, fake_attributes_for_publishing_api.to_json)

    RegisterableEdition.stubs(:new).with(edition).returns(fake_registerable_edition)

    PublishingApiRegisterArtefactWorker.new.perform(edition.id)

    assert_publishing_api_put_item(base_path, fake_attributes_for_publishing_api)
  end
end
