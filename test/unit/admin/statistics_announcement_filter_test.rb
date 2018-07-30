require 'test_helper'

class Admin::StatisticsAnnouncementFilterTest < ActiveSupport::TestCase
  setup do
    StatisticsAnnouncement.delete_all
  end

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
    _future    = statistics_announcement_for(1.day.from_now)
    last_month = statistics_announcement_for(1.month.ago)

    assert_equal [last_week, last_month].map(&:id),
      filter(dates: 'past').statistics_announcements.map(&:id)
  end

  test "filtering future releases returns them in date order" do
    today = statistics_announcement_for(1.hour.from_now)
    _past = statistics_announcement_for(1.week.ago)
    tomorrow = statistics_announcement_for(1.day.from_now)
    _last_month = statistics_announcement_for(1.month.ago)

    assert_equal [today, tomorrow].map(&:id),
      filter(dates: 'future').statistics_announcements.map(&:id)
  end

  test "filtering for imminent announcements returns them in date order" do
    today = statistics_announcement_for(1.hour.from_now)
    _past = statistics_announcement_for(1.week.ago)
    tomorrow = statistics_announcement_for(1.day.from_now)
    _one_month = statistics_announcement_for(1.month.from_now)

    assert_equal [today, tomorrow].map(&:id),
      filter(dates: 'imminent').statistics_announcements.map(&:id)
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
    match = create(:statistics_announcement, title: "MQ5 statistics")
    _no_match = create(:statistics_announcement, title: "PQ5 statistics")

    assert_equal [match], filter(title: "mq5").statistics_announcements
  end

  test "can filter by organisation" do
    organisation = create(:organisation)
    match        = create(:statistics_announcement, organisation_ids: [organisation.id])
    _no_match    = create(:statistics_announcement)

    assert_equal [match],
      filter(organisation_id: organisation.id).statistics_announcements
  end

  test "filter eager loads the correct date for an announcement when ordered ascending" do
    old_date     = Time.new(2014, 10, 1, 9, 30)
    new_date     = Time.new(2014, 10, 15, 9, 30)
    announcement = create(:statistics_announcement, release_date: old_date)
    date_change  = announcement.build_statistics_announcement_date_change(release_date: new_date)
    date_change.save!

    assert_equal 1,
      filter(dates: 'future').statistics_announcements.total_count

    assert_equal new_date,
      filter(dates: 'future').statistics_announcements[0].release_date
  end

  test "filter eager loads the correct date for an announcement when ordered descending" do
    old_date     = Time.new(2010, 10, 15, 9, 30)
    new_date     = Time.new(2010, 10, 1, 9, 30)
    announcement = create(:statistics_announcement, release_date: old_date)
    date_change  = announcement.build_statistics_announcement_date_change(release_date: new_date)
    date_change.save!

    assert_equal 1,
      filter(dates: 'past').statistics_announcements.total_count

    assert_equal new_date,
      filter(dates: 'past').statistics_announcements[0].release_date
  end

  test "#title gives the high-level description for the announcements being returned, based on organisation" do
    organisation = create(:organisation, name: "Department of stuff")

    assert_equal "Everyone’s statistics announcements", filter.title

    assert_equal "Department of stuff’s statistics announcements",
      filter(organisation_id: organisation.id).title
  end

  test "#title reflects when the provided user belongs to the filtered organisation" do
    organisation = create(:organisation)
    user         = create(:writer, organisation: organisation)

    assert_equal "My organisation’s statistics announcements",
      filter(organisation_id: organisation.id, user_id: user.id).title
  end

  test "#title handles possessive apostrophe correctly" do
    organisation = create(:organisation, name: "Department of things")

    assert_equal "Department of things’ statistics announcements",
      filter(organisation_id: organisation.id).title
  end

  test "#description describes future statistics announcements" do
    create(:statistics_announcement, release_date: next_week)

    assert_equal "1 upcoming statistics release",
      filter(dates: 'future').description

    2.times { create(:statistics_announcement, release_date: next_week) }

    assert_equal "3 upcoming statistics releases",
      filter(dates: 'future').description
  end

  test "#description describes past releases" do
    create(:statistics_announcement, release_date: past_date)
    assert_equal "1 statistics announcement in the past", filter(dates: 'past').description

    create(:statistics_announcement, release_date: past_date)
    assert_equal "2 statistics announcements in the past", filter(dates: 'past').description
  end

  test "#description describes all releases" do
    create(:statistics_announcement, release_date: past_date)
    assert_equal "1 statistics announcement", filter.description

    create(:statistics_announcement, release_date: next_week)
    assert_equal "2 statistics announcements", filter.description
  end

  test "#description describes imminent releases" do
    2.times { create(:statistics_announcement, release_date: next_year) }

    create(:statistics_announcement, release_date: next_week)
    assert_equal "1 statistics release due in two weeks",
      filter(dates: "imminent").description

    create(:statistics_announcement, release_date: next_week)
    assert_equal "2 statistics releases due in two weeks",
      filter(dates: "imminent").description
  end

  test "#description mentions if filtering by unlinked publications" do
    3.times { create(:statistics_announcement) }
    create(:statistics_announcement, publication: create(:draft_statistics))

    assert_equal "3 statistics announcements (without a publication)",
      filter(unlinked_only: '1').description
  end

  test "excludes unpublished announcements" do
    stub_any_publishing_api_call
    _deleted = create(:unpublished_statistics_announcement)
    published = create(:statistics_announcement)

    assert_equal [published.id], filter.statistics_announcements.map(&:id)
  end

private

  def statistics_announcement_for(datetime, attributes = {})
    create(:statistics_announcement, attributes.reverse_merge(release_date: datetime))
  end

  def filter(options = {})
    Admin::StatisticsAnnouncementFilter.new(options)
  end

  def past_date
    1.week.ago
  end

  def next_week
    1.week.from_now
  end

  def next_year
    2.year.from_now
  end
end
