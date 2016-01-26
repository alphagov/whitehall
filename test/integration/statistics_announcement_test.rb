require "test_helper"
require "gds_api/test_helpers/publishing_api_v2"

class StatisticsAnnouncementTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = false

  setup do
    DatabaseCleaner.clean_with :truncation
    stub_any_publishing_api_call
  end

  test "StatisticsAnnouncement is published to the Publishing API when saved" do
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

  test "StatisticsAnnouncement publishes gone on destroy" do
    statistics_announcement = create(:statistics_announcement)

    new_content_id = SecureRandom.uuid
    SecureRandom.stubs(uuid: new_content_id)

    presenter = PublishingApiPresenters::Gone.new(statistics_announcement.search_link)
    expected = presenter.content

    statistics_announcement.destroy
    assert_publishing_api_put_content(new_content_id, expected)
  end

  test "StatisticAnnouncment publishes when updated" do
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
end
