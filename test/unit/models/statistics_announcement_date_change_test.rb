require 'test_helper'

class StatisticsAnnouncementDateChangeTest < ActiveSupport::TestCase
  test "a change to a confirmed release date requires a change note" do
    current_date = build(:statistics_announcement_date,
                         precision: StatisticsAnnouncementDate::PRECISION[:exact],
                         confirmed: true)

    new_date = build(:statistics_announcement_date_change,
                     current_release_date: current_date,
                     precision: StatisticsAnnouncementDate::PRECISION[:exact],
                     confirmed: true,
                     release_date: (current_date.release_date + 1.day))

    refute new_date.valid?
    assert_match /required/, new_date.errors[:change_note].first
  end

  test "unconfirming a confirmed release date requires a change note" do
    current_date = build(:statistics_announcement_date,
                         precision: StatisticsAnnouncementDate::PRECISION[:exact],
                         confirmed: true)

    new_date = build(:statistics_announcement_date_change,
                     current_release_date: current_date,
                     precision: StatisticsAnnouncementDate::PRECISION[:exact],
                     release_date: current_date.release_date,
                     confirmed: false)

    refute new_date.valid?
    assert_match /required/, new_date.errors[:change_note].first
  end

  test "a change to a provisional release date is valid and ignores the change note" do
    announcement = create(:statistics_announcement)
    new_date = announcement.build_statistics_announcement_date_change(
      release_date: (announcement.release_date + 1.year),
      change_note: 'Not required so will be ignored'
    )

    assert new_date.save
    assert_nil new_date.reload.change_note
  end

  test "improving the precision of provisional date is valid and ignores the change note" do
    announcement = create(:statistics_announcement)
    new_date = announcement.build_statistics_announcement_date_change(
      precision: StatisticsAnnouncementDate::PRECISION[:exact],
      release_date: announcement.release_date + 2.months)

    assert new_date.save
    assert_nil new_date.reload.change_note
  end

  test "saving a date change updates the announcement" do
    announcement = create(:statistics_announcement)
    Timecop.return

    new_date = announcement.build_statistics_announcement_date_change
    new_date.save!

    assert announcement.updated_at > announcement.created_at,
      "StatisticsAnnouncement has not been updated"
  end
end
