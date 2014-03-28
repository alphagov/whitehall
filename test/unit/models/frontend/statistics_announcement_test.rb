require 'test_helper'

class Frontend::StatisticsAnnouncementTest < ActiveSupport::TestCase
  def build_announcement(attrs = {})
    Frontend::StatisticsAnnouncement.new(attrs)
  end

  test "#release_date= should parse strings into dates" do
    announcement = build_announcement(release_date: "2016-02-01 10:45:00 +0000")
    assert announcement.release_date.is_a? ActiveSupport::TimeWithZone
    assert_equal "February 01, 2016 10:45", announcement.release_date.to_s(:long)
  end

  test "#display_date_with_confirmed_status appends (confirmed) to confirmed announcements" do
    announcement =  build_announcement(display_date: "March 12 2015", release_date_confirmed: true)
    assert_equal "March 12 2015 (confirmed)", announcement.display_date_with_confirmed_status
  end

  test "#display_date_with_confirmed_status appends (provisional) to unconfirmed announcements" do
    announcement =  build_announcement(display_date: "March 12 2015", release_date_confirmed: false)
    assert_equal "March 12 2015 (provisional)", announcement.display_date_with_confirmed_status
  end

  test "it identifies by it's slug" do
    assert_equal 'a-slug', build_announcement(slug: 'a-slug').to_param
  end
end
