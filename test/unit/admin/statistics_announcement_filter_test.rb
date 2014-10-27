require 'test_helper'

class Admin::StatisticsAnnouncementFilterTest < ActiveSupport::TestCase
  test "returns statistics announcements in reverse date order" do
    last_week  = statistics_announcement_for(1.week.ago)
    tomorrow   = statistics_announcement_for(1.day.from_now)
    yesterday  = statistics_announcement_for(1.day.ago)
    last_month = statistics_announcement_for(1.month.ago)

    assert_equal [tomorrow, yesterday, last_week, last_month],
      filter.statistics_announcements
  end

  test "filtering past releases returns them in reverse date order" do
    last_week  = statistics_announcement_for(1.week.ago)
    future     = statistics_announcement_for(1.day.from_now)
    last_month = statistics_announcement_for(1.month.ago)

    assert_equal [last_week, last_month].map(&:id),
      filter(dates: 'past').statistics_announcements.map(&:id)
  end

  test "filtering future releases returns them in date order" do
    today      = statistics_announcement_for(1.hour.from_now)
    past       = statistics_announcement_for(1.week.ago)
    tomorrow   = statistics_announcement_for(1.day.from_now)
    last_month = statistics_announcement_for(1.month.ago)

    assert_equal [today, tomorrow].map(&:id),
      filter(dates: 'future').statistics_announcements.map(&:id)
  end

  test "filtering the next four weeks of announcements returns them in date order" do
    today      = statistics_announcement_for(1.hour.from_now)
    past       = statistics_announcement_for(1.week.ago)
    tomorrow   = statistics_announcement_for(1.day.from_now)
    two_months = statistics_announcement_for(2.month.from_now)

    assert_equal [today, tomorrow].map(&:id),
      filter(dates: 'four-weeks').statistics_announcements.map(&:id)
  end

  test "can filter only those announcements that do not have a linked publication" do
    today     = statistics_announcement_for(1.hour.from_now, publication: create(:draft_statistics))
    tomorrow  = statistics_announcement_for(1.day.from_now, publication: create(:draft_statistics))
    yesterday = statistics_announcement_for(1.day.ago)
    next_week = statistics_announcement_for(1.week.from_now)

    assert_equal [next_week, tomorrow, today, yesterday],
      filter.statistics_announcements

    assert_equal [next_week, yesterday],
      filter(unlinked_only: '1').statistics_announcements

    assert_equal [next_week],
      filter(dates: 'future', unlinked_only: '1').statistics_announcements
  end

  test "can filter by title" do
    match    = create(:statistics_announcement, title: "MQ5 statistics")
    no_match = create(:statistics_announcement, title: "PQ5 statistics")

    assert_equal [match], filter(title: "mq5").statistics_announcements
  end

  test "can filter by organisation" do
    organisation = create(:organisation)
    match        = create(:statistics_announcement, organisation_ids: [organisation.id])
    no_match     = create(:statistics_announcement)

    assert_equal [match],
      filter(organisation_id: organisation.id).statistics_announcements
  end

  test "#title gives the high-level description for the announcements being returned, based on organisation" do
    organisation = create(:organisation, name: "Department of stuff")

    assert_equal "Everyone’s statistics announcements", filter.title

    assert_equal "Department of stuff’s statistics announcements",
      filter(organisation_id: organisation.id).title
  end

  test "#title reflects when the provided user belongs to the filtered organisation" do
    organisation = create(:organisation)
    user         = create(:policy_writer, organisation: organisation)

    assert_equal "My organisation’s statistics announcements",
      filter(organisation_id: organisation.id, user_id: user.id).title
  end

  test "#title handles possessive apostrophe correctly" do
    organisation = create(:organisation, name: "Department of things")

    assert_equal "Department of things’ statistics announcements",
      filter(organisation_id: organisation.id).title
  end

private

  def statistics_announcement_for(datetime, attributes={})
    create(:statistics_announcement, attributes.reverse_merge(
      current_release_date: create(:statistics_announcement_date, release_date: datetime)
    ))
  end

  def filter(options={})
    Admin::StatisticsAnnouncementFilter.new(options)
  end
end
