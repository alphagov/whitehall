require 'test_helper'

class Frontend::StatisticalReleaseAnnouncementTest < ActiveSupport::TestCase
  def build(attrs = {})
    Frontend::StatisticalReleaseAnnouncement.new(attrs)
  end

  test "#release_date_text should return release_date in long format if release_date_text is not provided" do
    assert_equal "In the far future", build(expected_release_date: 1.day.from_now, display_release_date: "In the far future").release_date_text
    assert_equal 1.day.from_now.to_s(:long), build(expected_release_date: 1.day.from_now, display_release_date: nil).release_date_text
  end
end
