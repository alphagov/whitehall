require 'test_helper'

class StatisticsAnnouncementDateTest < ActiveSupport::TestCase
  test 'must have valid precision' do
    StatisticsAnnouncementDate::PRECISION.each_value do |value|
      assert build(:statistics_announcement_date, precision: value).valid?
    end

    assert_not build(:statistics_announcement_date, precision: 42).valid?
  end

  test '#display_date gives exact date when precision is :exact' do
    annoucement_date = build(:statistics_announcement_date,
                             precision: StatisticsAnnouncementDate::PRECISION[:exact],
                             release_date: Time.zone.new(2013, 11, 10, 9, 30))

    assert_equal '10 November 2013 9:30am', annoucement_date.display_date
  end

  test '#display_date gives month of release when precision is :one_month' do
    annoucement_date = build(:statistics_announcement_date,
                             precision: StatisticsAnnouncementDate::PRECISION[:one_month],
                             release_date: Time.zone.new(2013, 7, 10, 9, 30))

    assert_equal 'July 2013', annoucement_date.display_date
  end

  test '#display_date gives two month range when precision is :two_month' do
    annoucement_date = build(:statistics_announcement_date,
                             precision: StatisticsAnnouncementDate::PRECISION[:two_month],
                             release_date: Time.zone.new(2014, 12, 10, 9, 30))

    assert_equal 'December to January 2015', annoucement_date.display_date
  end

  test 'a confirmed date must be of exact precision' do
    assert_not build(:statistics_announcement_date,
                 precision: StatisticsAnnouncementDate::PRECISION[:one_month],
                 confirmed: true).valid?

    assert_not build(:statistics_announcement_date,
                 precision: StatisticsAnnouncementDate::PRECISION[:two_month],
                 confirmed: true).valid?

    assert build(:statistics_announcement_date,
                 precision: StatisticsAnnouncementDate::PRECISION[:exact],
                 confirmed: true).valid?
  end
end
