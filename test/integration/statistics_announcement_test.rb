require "test_helper"
require "gds_api/test_helpers/publishing_api_v2"

class StatisticsAnnouncementTest < ActiveSupport::TestCase
  self.use_transactional_tests = false

  # Similar methods to these exist in `gds_api/test_helpers/publishing_api`.
  # To avoid clashes between v1 and v2 helpers, we've reimplemented them here,
  # as `publish_intents` only exist in v1 and there's no plan to reimplement them
  # as their functionality will ultimately be included in `publishing-api`.
  PUBLISHING_API_V1_ENDPOINT = Plek.current.find('publishing-api')

  def assert_publishing_api_put_intent(base_path, attributes = {}, times = 1)
    intent_url = PUBLISHING_API_V1_ENDPOINT + "/publish-intent" + base_path
    assert_requested(:put, intent_url, times: times, body: attributes)
  end

  def assert_publishing_api_delete_intent(base_path, times = 1)
    intent_url = PUBLISHING_API_V1_ENDPOINT + "/publish-intent" + base_path
    assert_requested(:delete, intent_url, times: times)
  end

  setup do
    DatabaseCleaner.clean_with :truncation
    stub_any_publishing_api_call
  end

  test "it gets published to the Publishing API when saved" do
    Sidekiq::Testing.inline! do
      statistics_announcement = build(:statistics_announcement)
      presenter = PublishingApiPresenters.presenter_for(statistics_announcement)

      statistics_announcement.save!

      expected = presenter.content.merge(
        public_updated_at: Time.zone.now.as_json
      )

      expected_intent = PublishingApi::PublishIntentPresenter.new(
        statistics_announcement.base_path,
        statistics_announcement.statistics_announcement_dates.last.release_date
      )

      assert_publishing_api_put_content(statistics_announcement.content_id,
                                        expected)
      assert_publishing_api_publish(statistics_announcement.content_id,
                                    { update_type: "minor", locale: "en" }, 1)
      assert_publishing_api_put_intent(
        statistics_announcement.base_path,
        expected_intent.as_json
      )
    end
  end

  test "it publishes gone on destroy" do
    Sidekiq::Testing.inline! do
      statistics_announcement = create(:statistics_announcement)
      gone_request = stub_publishing_api_unpublish(
        statistics_announcement.content_id,
        body: {
          type: "gone",
          locale: "en",
          discard_drafts: true,
        }
      )

      statistics_announcement.destroy
      assert_requested gone_request
    end
  end

  test "it publishes when updated" do
    Sidekiq::Testing.inline! do
      statistics_announcement = create(:statistics_announcement)
      statistics_announcement.attributes = { title: "New Title" }
      statistics_announcement.save!

      presenter = PublishingApiPresenters.presenter_for(statistics_announcement)
      expected = presenter.content.merge(
        public_updated_at: Time.zone.now.as_json
      )

      expected_intent = PublishingApi::PublishIntentPresenter.new(
        statistics_announcement.base_path,
        statistics_announcement.statistics_announcement_dates.last.release_date
      )

      assert_publishing_api_put_content(statistics_announcement.content_id,
                                        expected)
      assert_publishing_api_publish(statistics_announcement.content_id,
                                    { update_type: "minor", locale: "en" }, 2)
      assert_publishing_api_put_intent(
        statistics_announcement.base_path,
        expected_intent.as_json,
        2
      )
    end
  end

  test "it deletes the publish intent when unpublished" do
    Sidekiq::Testing.inline! do
      statistics_announcement = create(:statistics_announcement)
      statistics_announcement.update_attributes!(publishing_state: "unpublished",
                                                 redirect_url: "https://www.test.gov.uk/example")

      assert_publishing_api_delete_intent(statistics_announcement.base_path)
    end
  end

  test "it deletes the publish intent when cancelled" do
    Sidekiq::Testing.inline! do
      statistics_announcement = create(:statistics_announcement)
      statistics_announcement.cancel!("testing", User.new(id: 1))

      assert_publishing_api_delete_intent(statistics_announcement.base_path)
    end
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
                                     redirect_url: "https://www.test.gov.uk/example")

    Whitehall::SearchIndex.expects(:delete).with(statistics_announcement)
    statistics_announcement.update_attributes!(publishing_state: "unpublished")
  end

  test "it is republished when the date is changed" do
    Sidekiq::Testing.inline! do
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

      expected_intent = PublishingApi::PublishIntentPresenter.new(
        statistics_announcement.base_path,
        statistics_announcement.statistics_announcement_dates.last.release_date
      )

      assert_publishing_api_put_content(statistics_announcement.content_id,
                                        request_json_includes(expected))
      assert_publishing_api_publish(statistics_announcement.content_id,
                                    { update_type: "minor", locale: "en" }, 2)
      assert_publishing_api_put_intent(
        statistics_announcement.base_path,
        expected_intent.as_json,
        2
      )
    end
  end

  test "it is redirected to its associated publication when the publication is published" do
    statistics = create(:draft_statistics)
    statistics_announcement = create(:statistics_announcement, publication: statistics)

    Whitehall::PublishingApi.expects(:publish_redirect_async)
      .with(statistics_announcement.content_id, "/government/statistics/#{statistics.slug}")

    Whitehall.edition_services.force_publisher(statistics).perform!
  end

  test "it is redirected to an alternate URL when unpublished" do
    statistics_announcement = create(:statistics_announcement)

    Whitehall::PublishingApi.expects(:publish_redirect_async)
      .with(statistics_announcement.content_id, "https://www.test.gov.uk/government/something-else")

    statistics_announcement.update_attributes!(
      publishing_state: "unpublished",
      redirect_url: "https://www.test.gov.uk/government/something-else"
    )
  end
end
