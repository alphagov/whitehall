require "test_helper"
require "gds_api/test_helpers/publishing_api_v2"

class StatisticsAnnouncementTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = false

  setup do
    DatabaseCleaner.clean_with :truncation
    stub_any_publishing_api_call
  end

  test "it gets published to the Publishing API when saved" do
    statistics_announcement = build(:statistics_announcement)
    presenter = PublishingApiPresenters.presenter_for(statistics_announcement)

    statistics_announcement.save!

    expected = presenter.content.merge(
      public_updated_at: Time.zone.now.as_json
    )

    assert_publishing_api_put_content(statistics_announcement.content_id,
                                      expected)
    assert_publishing_api_publish(statistics_announcement.content_id,
                                  { update_type: "major", locale: "en" }, 1)
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

    assert_publishing_api_put_content(statistics_announcement.content_id,
                                      expected)
    assert_publishing_api_publish(statistics_announcement.content_id,
                                  { update_type: "major", locale: "en" }, 2)
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

    assert_publishing_api_put_content(statistics_announcement.content_id,
                                      request_json_includes(expected))
    assert_publishing_api_publish(statistics_announcement.content_id,
                                  { update_type: "major", locale: "en" }, 2)
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
