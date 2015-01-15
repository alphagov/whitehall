require "test_helper"
require "gds_api/test_helpers/publishing_api"
require "gds_api/test_helpers/panopticon"

class PublishingTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::PublishingApi
  include GdsApi::TestHelpers::Panopticon

  setup do
    @draft_edition = create(:draft_edition)
    @presenter = PublishingApiPresenters.presenter_for(@draft_edition)
    stub_panopticon_registration(@draft_edition)
  end

  test "When an edition is published, it gets published with the Publishing API" do
    expected_attributes = @presenter.as_json.merge(
      # This is to simulate what the time public timestamp will be after the
      # edition has been published
      public_updated_at: Time.zone.now.as_json
    )
    request = stub_publishing_api_put_item(@presenter.base_path, expected_attributes)

    perform_force_publishing_for(@draft_edition)

    assert_requested request
  end

  test "When a translated edition is published, all translations are published with the Publishing API" do
   I18n.with_locale :fr do
      @draft_edition.title = "French title"
      @draft_edition.save!

      expected_attributes = @presenter.as_json.merge(public_updated_at: Time.zone.now.as_json)
      @french_request = stub_publishing_api_put_item(@presenter.base_path, expected_attributes)
   end

   expected_attributes = @presenter.as_json.merge(public_updated_at: Time.zone.now.as_json)
   @english_request = stub_publishing_api_put_item(@presenter.base_path, expected_attributes)

   perform_force_publishing_for(@draft_edition)

   assert_requested @english_request
   assert_requested @french_request
  end

  private

  def perform_force_publishing_for(edition)
    Whitehall.edition_services.force_publisher(edition).perform!
  end
end
