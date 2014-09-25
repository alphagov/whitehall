require "test_helper"
require "gds_api/test_helpers/publishing_api"
require "gds_api/test_helpers/panopticon"

class PublishingTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::PublishingApi
  include GdsApi::TestHelpers::Panopticon

  setup do
    @draft_edition = create(:draft_edition)
    @registerable = RegisterableEdition.new(@draft_edition)
    stub_artefact_registration(@registerable.slug)
  end

  test "When publishing an edition, it is registered in the publishing api" do
    expected_attributes = @registerable.attributes_for_publishing_api.merge(
      public_updated_at: Time.zone.now.iso8601
    )
    @request = stub_publishing_api_put_item(@registerable.base_path, expected_attributes)

    perform_force_publishing_for(@draft_edition)

    assert_requested @request
  end

  private

  def perform_force_publishing_for(edition)
    Whitehall.edition_services.force_publisher(edition).perform!
  end
end
