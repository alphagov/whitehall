require "test_helper"
require "gds_api/test_helpers/publishing_api_v2"
require "gds_api/test_helpers/panopticon"

class PublishingTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::PublishingApiV2
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
    requests = stub_publishing_api_put_content_links_and_publish(expected_attributes)

    perform_force_publishing_for(@draft_edition)

    assert_all_requested(requests)
  end

  test "When a translated edition is published, all translations are published with the Publishing API" do
   I18n.with_locale :fr do
      @draft_edition.title = "French title"
      @draft_edition.save!

      expected_attributes = @presenter.as_json.merge(public_updated_at: Time.zone.now.as_json)
      @french_requests = stub_publishing_api_put_content_links_and_publish(expected_attributes)
   end

   expected_attributes = @presenter.as_json.merge(public_updated_at: Time.zone.now.as_json)
   @english_requests = stub_publishing_api_put_content_links_and_publish(expected_attributes)

   perform_force_publishing_for(@draft_edition)

   assert_all_requested(@english_requests)
   assert_all_requested(@french_requests)
  end

  private

  def perform_force_publishing_for(edition)
    Whitehall.edition_services.force_publisher(edition).perform!
  end
end
