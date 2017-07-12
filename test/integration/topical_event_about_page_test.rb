require "test_helper"
require "gds_api/test_helpers/publishing_api_v2"

class TopicalEventAboutPageTest < ActiveSupport::TestCase
  #api calls happen in after commit so we need to disable transactions
  self.use_transactional_tests = false

  setup do
    DatabaseCleaner.clean_with :truncation
    stub_any_publishing_api_call
    @topical_event_about_page = build(:topical_event_about_page)
  end

  test "TopicalEventAboutPage is published to the Publishing API on save" do
    presenter = PublishingApiPresenters.presenter_for(@topical_event_about_page)

    @topical_event_about_page.save!

    expected_json = presenter.content.merge(
      # This is to simulate what the time public timestamp will be after the
      # page has been published
      public_updated_at: Time.zone.now.as_json
    )

    assert_publishing_api_put_content(@topical_event_about_page.content_id, expected_json)
    assert_publishing_api_publish(
      @topical_event_about_page.content_id,
      {
        update_type: 'major',
        locale: 'en'
      },
      1
    )
  end

  test "TopicalEventAboutPage publishes gone route to the Publishing API on destroy" do
    @topical_event_about_page.save!

    gone_request = stub_publishing_api_unpublish(
      @topical_event_about_page.content_id,
      body: {
        type: "gone",
        locale: "en",
        discard_drafts: true,
      }
    )

    @topical_event_about_page.destroy
    assert_requested gone_request
  end

  test "TopicalEventAboutPage is published to the Publishing API when updated" do
    @topical_event_about_page.save!
    @topical_event_about_page.read_more_link_text = "New read more link text"
    @topical_event_about_page.save!
    presenter = PublishingApiPresenters.presenter_for(@topical_event_about_page)

    expected_json = presenter.content.merge(
      # This is to simulate what the time public timestamp will be after the
      # page has been published
      public_updated_at: Time.zone.now.as_json
    )

    assert_publishing_api_put_content(@topical_event_about_page.content_id, expected_json)
    assert_publishing_api_publish(
      @topical_event_about_page.content_id,
      {
        update_type: 'major',
        locale: 'en'
      },
      2
    )
  end
end
