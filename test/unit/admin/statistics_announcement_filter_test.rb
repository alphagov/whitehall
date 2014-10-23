require 'test_helper'

class Admin::StatisticsAnnouncementFilterTest < ActiveSupport::TestCase
  test "returns statistics announcements in reverse date order" do
    last_week  = create(:statistics_announcement, current_release_date: create(:statistics_announcement_date, release_date: 1.week.ago))
    tomorrow   = create(:statistics_announcement, current_release_date: create(:statistics_announcement_date, release_date: 1.day.from_now))
    yesterday  = create(:statistics_announcement, current_release_date: create(:statistics_announcement_date, release_date: 1.day.ago))
    last_month = create(:statistics_announcement, current_release_date: create(:statistics_announcement_date, release_date: 1.month.ago))
    filter     = Admin::StatisticsAnnouncementFilter.new

    assert_equal [tomorrow, yesterday, last_week, last_month],
      filter.statistics_announcements
  end

  test "can filter by title" do
    match    = create(:statistics_announcement, title: "MQ5 statistics")
    no_match = create(:statistics_announcement, title: "PQ5 statistics")
    filter   = Admin::StatisticsAnnouncementFilter.new(title: "mq5")

    assert_equal [match], filter.statistics_announcements
  end

  test "can filter by organisation" do
    organisation = create(:organisation)
    match        = create(:statistics_announcement, organisation_ids: [organisation.id])
    no_match     = create(:statistics_announcement)
    filter       = Admin::StatisticsAnnouncementFilter.new(organisation_id: organisation.id)

    assert_equal [match], filter.statistics_announcements
  end
end
