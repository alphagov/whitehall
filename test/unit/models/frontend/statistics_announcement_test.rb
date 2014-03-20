require 'test_helper'

class Frontend::StatisticsAnnouncementTest < ActiveSupport::TestCase
  def build_announcement(attrs = {})
    Frontend::StatisticsAnnouncement.new(attrs)
  end

  test "#release_date_text should return release_date in long format if release_date_text is not provided" do
    assert_equal "In the far future", build_announcement(release_date: 1.day.from_now, release_date_text: "In the far future").release_date_text
    assert_equal 1.day.from_now.to_s(:long), build_announcement(release_date: 1.day.from_now, release_date_text: nil).release_date_text
  end

  test "#release_date= should parse strings into dates" do
    announcement = build_announcement(release_date: "2016-02-01 10:45:00 +0000")
    assert announcement.release_date.is_a? ActiveSupport::TimeWithZone
    assert_equal "February 01, 2016 10:45", announcement.release_date.to_s(:long)
  end

  test "it identifies by it's slug" do
    assert_equal 'a-slug', build_announcement(slug: 'a-slug').to_param
  end
end
