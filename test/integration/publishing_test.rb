require "test_helper"
require "gds_api/test_helpers/publishing_api_v2"

class PublishingTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::PublishingApiV2

  setup do
    @draft_edition = create(:draft_edition)
    @presenter = PublishingApiPresenters.presenter_for(@draft_edition)
  end

  test "When an edition is published, it gets published with the Publishing API" do
    requests = [
      stub_publishing_api_publish(@presenter.content_id, locale: 'en', update_type: nil)
    ]

    perform_force_publishing_for(@draft_edition)

    assert_all_requested(requests)
  end

  test "When a translated edition is published, all translations are published with the Publishing API" do
    french_requests = I18n.with_locale :fr do
      @draft_edition.title = "French title"
      @draft_edition.save!

      [
        stub_publishing_api_publish(@presenter.content_id, locale: 'fr', update_type: nil)
      ]
    end

    english_requests = [
      stub_publishing_api_publish(@presenter.content_id, locale: 'en', update_type: nil)
    ]

    perform_force_publishing_for(@draft_edition)

    assert_all_requested(english_requests)
    assert_all_requested(french_requests)
  end

private

  def perform_force_publishing_for(edition)
    Whitehall.edition_services.force_publisher(edition).perform!
  end
end
