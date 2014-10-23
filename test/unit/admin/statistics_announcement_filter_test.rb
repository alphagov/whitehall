require 'test_helper'

class Admin::StatisticsAnnouncementFilterTest < ActiveSupport::TestCase
  test "returns statistics announcements in reverse date order" do
    last_week  = statistics_announcement_for(1.week.ago)
    tomorrow   = statistics_announcement_for(1.day.from_now)
    yesterday  = statistics_announcement_for(1.day.ago)
    last_month = statistics_announcement_for(1.month.ago)
    filter     = Admin::StatisticsAnnouncementFilter.new

    assert_equal [tomorrow, yesterday, last_week, last_month],
      filter.statistics_announcements
  end

  test "filtering past releases returns them in reverse date order" do
    last_week  = statistics_announcement_for(1.week.ago)
    future     = statistics_announcement_for(1.day.from_now)
    last_month = statistics_announcement_for(1.month.ago)
    filter     = Admin::StatisticsAnnouncementFilter.new(dates: 'past')

    assert_equal [last_week, last_month].map(&:id), filter.statistics_announcements.map(&:id)
  end

  test "filtering future releases returns them in date order" do
    today      = statistics_announcement_for(1.hour.from_now)
    past       = statistics_announcement_for(1.week.ago)
    tomorrow   = statistics_announcement_for(1.day.from_now)
    last_month = statistics_announcement_for(1.month.ago)
    filter     = Admin::StatisticsAnnouncementFilter.new(dates: 'future')

    assert_equal [today, tomorrow].map(&:id), filter.statistics_announcements.map(&:id)
  end

  test "can filter only those announcements that do not have a linked publication" do
    today     = statistics_announcement_for(1.hour.from_now, publication: create(:draft_statistics))
    tomorrow  = statistics_announcement_for(1.day.from_now, publication: create(:draft_statistics))
    yesterday = statistics_announcement_for(1.day.ago)
    next_week = statistics_announcement_for(1.week.from_now)

    assert_equal [next_week, tomorrow, today, yesterday],
      Admin::StatisticsAnnouncementFilter.new.statistics_announcements

    assert_equal [next_week, yesterday],
      Admin::StatisticsAnnouncementFilter.new(unlinked_only: '1').statistics_announcements

    assert_equal [next_week],
      Admin::StatisticsAnnouncementFilter.new(dates: 'future', unlinked_only: '1').statistics_announcements
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

private

  def statistics_announcement_for(datetime, attributes={})
    create(:statistics_announcement, attributes.reverse_merge(
      current_release_date: create(:statistics_announcement_date, release_date: datetime)
    ))
  end
end
