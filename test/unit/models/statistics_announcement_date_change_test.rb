require 'test_helper'

class StatisticsAnnouncementDateChangeTest < ActiveSupport::TestCase
  test "change note required if changing an exact date" do
    current_date  = build(:statistics_announcement_date,
                      precision: StatisticsAnnouncementDate::PRECISION[:exact])

    new_date      = build(:statistics_announcement_date_change,
                      current_release_date: current_date,
                      precision: StatisticsAnnouncementDate::PRECISION[:exact],
                      release_date: (current_date.release_date + 1.day))

    refute new_date.valid?
    assert_match /required/, new_date.errors[:change_note].first
  end

  test "change note required if changing date beyond a one-month precision" do
    current_date  = build(:statistics_announcement_date,
                      precision: StatisticsAnnouncementDate::PRECISION[:one_month])

    new_date      = build(:statistics_announcement_date_change,
                      current_release_date: current_date,
                      precision: StatisticsAnnouncementDate::PRECISION[:one_month],
                      release_date: current_date.release_date + 3.weeks)

    assert new_date.valid?
    new_date.release_date = current_date.release_date + 1.month

    refute new_date.valid?
    assert_match /required/, new_date.errors[:change_note].first
  end

  test "change note required if changing date beyond a two-month precision" do
    current_date  = build(:statistics_announcement_date,
                      precision: StatisticsAnnouncementDate::PRECISION[:two_month])

    new_date      = build(:statistics_announcement_date_change,
                      current_release_date: current_date,
                      precision: StatisticsAnnouncementDate::PRECISION[:two_month],
                      release_date: current_date.release_date + 6.weeks)

    assert new_date.valid?
    new_date.release_date = current_date.release_date + 2.months

    refute new_date.valid?
    assert_match /required/, new_date.errors[:change_note].first
  end

  test "change note required if reducing precision" do
    current_date  = build(:statistics_announcement_date,
                      precision: StatisticsAnnouncementDate::PRECISION[:one_month])

    new_date      = build(:statistics_announcement_date_change,
                      current_release_date: current_date,
                      precision: StatisticsAnnouncementDate::PRECISION[:two_month],
                      release_date: current_date.release_date)

    refute new_date.valid?
    assert_match /required/, new_date.errors[:change_note].first
  end

  test "valid if improving precision of date" do
    current_date  = build(:statistics_announcement_date,
                      precision: StatisticsAnnouncementDate::PRECISION[:one_month])

    new_date      = build(:statistics_announcement_date_change,
                      current_release_date: current_date,
                      precision: StatisticsAnnouncementDate::PRECISION[:exact],
                      release_date: current_date.release_date)

    assert new_date.valid?
  end

  test "valid if improving precision and changing date within previous precision" do
    current_date  = build(:statistics_announcement_date,
                      precision: StatisticsAnnouncementDate::PRECISION[:one_month])

    new_date      = build(:statistics_announcement_date_change,
                      current_release_date: current_date,
                      precision: StatisticsAnnouncementDate::PRECISION[:exact],
                      release_date: current_date.release_date + 3.weeks)

    assert new_date.valid?
  end

  test "change note required if improving precision, but changing date beyond previous precision" do
    current_date  = build(:statistics_announcement_date,
                      precision: StatisticsAnnouncementDate::PRECISION[:one_month])

    new_date      = build(:statistics_announcement_date_change,
                      current_release_date: current_date,
                      precision: StatisticsAnnouncementDate::PRECISION[:exact],
                      release_date: current_date.release_date + 5.weeks)

    refute new_date.valid?
    assert_match /required/, new_date.errors[:change_note].first
  end
end
