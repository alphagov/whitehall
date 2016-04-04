require "test_helper"
require "gds_api/test_helpers/publishing_api_v2"

class StatisticsAnnouncementTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = false

  # Similar methods to these exist in `gds_api/test_helpers/publishing_api`.
  # To avoid clashes between v1 and v2 helpers, we've reimplemented them here,
  # as `publish_intents` only exist in v1 and there's no plan to reimplement them
  # as their functionality will ultimately be included in `publishing-api`.
  PUBLISHING_API_V1_ENDPOINT = Plek.current.find('publishing-api')

  def assert_publishing_api_put_intent(base_path, attributes = {}, times = 1)
    intent_url = PUBLISHING_API_V1_ENDPOINT + "/publish-intent" + base_path
    assert_requested(:put, intent_url, {times: times, body: attributes})
  end

  def assert_publishing_api_delete_intent(base_path, times = 1)
    intent_url = PUBLISHING_API_V1_ENDPOINT + "/publish-intent" + base_path
    assert_requested(:delete, intent_url, {times: times})
  end

  setup do
    DatabaseCleaner.clean_with :truncation
    stub_any_publishing_api_call
    # Additionally, stub v1 requests, while we need to support `publish_intents`.
    stub_request(:any, %r{\A#{PUBLISHING_API_V1_ENDPOINT}})
  end

  test "it gets published to the Publishing API when saved" do
    statistics_announcement = build(:statistics_announcement)
    presenter = PublishingApiPresenters.presenter_for(statistics_announcement)

    statistics_announcement.save!

    expected = presenter.content.merge(
      public_updated_at: Time.zone.now.as_json
    )

    expected_intent = PublishingApiPresenters::PublishIntent.new(
      statistics_announcement.base_path,
      statistics_announcement.statistics_announcement_dates.last.release_date
    )

    assert_publishing_api_put_content(statistics_announcement.content_id,
                                      expected)
    assert_publishing_api_publish(statistics_announcement.content_id,
                                  { update_type: "major", locale: "en" }, 1)
    assert_publishing_api_put_intent(
      statistics_announcement.base_path,
      expected_intent.as_json
    )
  end

  test "it publishes gone on destroy" do
    statistics_announcement = create(:statistics_announcement)

    new_content_id = SecureRandom.uuid
    SecureRandom.stubs(uuid: new_content_id)

    presenter = PublishingApiPresenters::Gone.new(statistics_announcement.search_link)
    expected = presenter.content

    statistics_announcement.destroy
    assert_publishing_api_put_content(new_content_id, expected)
  end

  test "it publishes when updated" do
    statistics_announcement = create(:statistics_announcement)
    statistics_announcement.attributes = { title: "New Title" }
    statistics_announcement.save!

    presenter = PublishingApiPresenters.presenter_for(statistics_announcement)
    expected = presenter.content.merge(
      public_updated_at: Time.zone.now.as_json
    )

    expected_intent = PublishingApiPresenters::PublishIntent.new(
      statistics_announcement.base_path,
      statistics_announcement.statistics_announcement_dates.last.release_date
    )

    assert_publishing_api_put_content(statistics_announcement.content_id,
                                      expected)
    assert_publishing_api_publish(statistics_announcement.content_id,
                                  { update_type: "major", locale: "en" }, 2)
    assert_publishing_api_put_intent(
      statistics_announcement.base_path,
      expected_intent.as_json,
      2
    )
  end

  test "it redirects when unpublished" do
    statistics_announcement = create(:statistics_announcement)
    new_content_id = SecureRandom.uuid
    SecureRandom.stubs(:uuid).returns(new_content_id)
    statistics_announcement.update_attributes!(publishing_state: "unpublished",
                                               redirect_url: "https://www.test.alphagov.co.uk/example")

    expected = PublishingApiPresenters::StatisticsAnnouncementRedirect.new(statistics_announcement).content

    assert_publishing_api_put_content(new_content_id,
                                      expected)
    assert_publishing_api_publish(new_content_id,
                                  { update_type: "major", locale: "en" }, 1)
  end

  test "it deletes the publish intent when unpublished" do
    statistics_announcement = create(:statistics_announcement)
    statistics_announcement.update_attributes!(publishing_state: "unpublished",
                                               redirect_url: "https://www.test.alphagov.co.uk/example")

    assert_publishing_api_delete_intent(statistics_announcement.base_path)
  end

  test "it deletes the publish intent when cancelled" do
    statistics_announcement = create(:statistics_announcement)
    statistics_announcement.cancel!("testing", User.new(id: 1))

    assert_publishing_api_delete_intent(statistics_announcement.base_path)
  end

  test "it is added to the search index when created" do
    Whitehall::SearchIndex.stubs(:add)
    statistics_announcement = build(:statistics_announcement)
    Whitehall::SearchIndex.expects(:add).with(statistics_announcement)

    statistics_announcement.save!
  end

  test "it is added to the search index when updated" do
    Whitehall::SearchIndex.stubs(:add)
    Whitehall::SearchIndex.expects(:add).with do |instance|
      instance.is_a?(StatisticsAnnouncement) &&
        instance.title == "updated title"
    end

    statistics_announcement = create(:statistics_announcement)
    statistics_announcement.title = "updated title"
    statistics_announcement.save!
  end

  test "it is removed from the search index when unpublished" do
    Whitehall::SearchIndex.stubs(:add)
    Whitehall::SearchIndex.stubs(:delete)
    statistics_announcement = create(:statistics_announcement,
                                     redirect_url: "https://www.test.alphagov.co.uk/example")

    Whitehall::SearchIndex.expects(:delete).with(statistics_announcement)
    statistics_announcement.update_attributes!(publishing_state: "unpublished")
  end

  test "it is republished when the date is changed" do
    Timecop.return
    statistics_announcement = create(:statistics_announcement)

    date_change_attrs = attributes_for(:statistics_announcement_date_change)
    date_change = statistics_announcement.build_statistics_announcement_date_change(date_change_attrs)
    date_change.save!

    expected = {
      details: {
        display_date: date_change.display_date,
        state: "confirmed",
        format_sub_type: "official"
      }
    }

    expected_intent = PublishingApiPresenters::PublishIntent.new(
      statistics_announcement.base_path,
      statistics_announcement.statistics_announcement_dates.last.release_date
    )

    assert_publishing_api_put_content(statistics_announcement.content_id,
                                      request_json_includes(expected))
    assert_publishing_api_publish(statistics_announcement.content_id,
                                  { update_type: "major", locale: "en" }, 2)
    assert_publishing_api_put_intent(
      statistics_announcement.base_path,
      expected_intent.as_json,
      2
    )
  end

  test "a redirect is published if saved when its associated Publication has
    been published" do
    published_statistics = create(:published_statistics)
    statistics_announcement = build(
      :statistics_announcement,
      publication: published_statistics
    )

    new_content_id = SecureRandom.uuid
    SecureRandom.stubs(:uuid).returns(new_content_id)

    statistics_announcement.save!

    expected = PublishingApiPresenters::StatisticsAnnouncementRedirect.new(statistics_announcement).content

    assert_publishing_api_put_content(new_content_id,
                                      expected)
    assert_publishing_api_publish(new_content_id,
                                  { update_type: "major", locale: "en" }, 3)
  end
end
