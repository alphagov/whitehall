require 'test_helper'

class Admin::StatisticsAnnouncementFilterTest < ActiveSupport::TestCase
  test "should filter by title" do
    match = create(:statistics_announcement, title: "MQ5 statistics")
    no_match = create(:statistics_announcement, title: "PQ5 statistics")

    assert_equal [match], Admin::StatisticsAnnouncementFilter.new(title: "mq5").statistics_announcements
  end
end
