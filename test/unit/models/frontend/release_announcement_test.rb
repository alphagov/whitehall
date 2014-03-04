require 'test_helper'

class Frontend::ReleaseAnnouncementTest < ActiveSupport::TestCase
  def build(attrs = {})
    Frontend::ReleaseAnnouncement.new(attrs)
  end

  test "It should accept attrs keyed by strings" do
    assert_equal "Announcing Announciation Announcements", build("title" => "Announcing Announciation Announcements").title
  end

  test "#release_date_text should return release_date in long format if release_date_text is not provided" do
    assert_equal "In the far future", build(release_date: 1.day.from_now, release_date_text: "In the far future").release_date_text
    assert_equal 1.day.from_now.to_s(:long), build(release_date: 1.day.from_now, release_date_text: nil).release_date_text
  end
end
