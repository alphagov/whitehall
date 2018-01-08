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

  test "#cancellation_date= should parse strings into dates" do
    announcement = build_announcement(cancellation_date: "2016-02-01 10:45:00 +0000")
    assert announcement.cancellation_date.is_a? ActiveSupport::TimeWithZone
    assert_equal "February 01, 2016 10:45", announcement.cancellation_date.to_s(:long)
  end

  test "#display_date_with_status appends (confirmed) to confirmed announcements" do
    announcement =  build_announcement(display_date: "March 12 2015", state: "confirmed")
    assert_equal "March 12 2015 (confirmed)", announcement.display_date_with_status
  end

  test "#display_date_with_status appends (provisional) to unconfirmed announcements" do
    announcement = build_announcement(display_date: "March 12 2015", state: "provisional")
    assert_equal "March 12 2015 (provisional)", announcement.display_date_with_status
  end

  test "#disply_date_with_status appends (cancelled) to cancelled announcements" do
    announcement = build_announcement(display_date: "March 12 2015", state: "cancelled")
    assert_equal "March 12 2015 (cancelled)", announcement.display_date_with_status
  end

  test "it identifies by its slug" do
    assert_equal 'a-slug', build_announcement(slug: 'a-slug').to_param
  end

  test "#national_statistic? is true if the document_type is 'National Statistics'" do
    assert build_announcement(document_type: "National Statistics").national_statistic?
    refute build_announcement(document_type: "Statistics").national_statistic?
  end
end
