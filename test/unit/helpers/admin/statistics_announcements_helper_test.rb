require "test_helper"

class Admin::StatisticsAnnouncementsHelperTest < ActionView::TestCase
  def absolute_time(*_args)
    "absolute_time"
  end

  def linked_author(*_args)
    "linked_author"
  end

  test "should render cancel statement when statistics announcement is cancelled and has a user" do
    user = build(:user)

    statistics_announcement = build(:cancelled_statistics_announcement, cancelled_by: user)

    result = statistics_announcements_history_list(statistics_announcement).first

    assert_includes(result, "Announcement cancelled")
    assert_includes(result, "linked_author")
    assert_not_includes(result, "User (removed)")
  end

  test "should render cancel statement when statistics announcement is cancelled and does not have a user" do
    statistics_announcement = build(:cancelled_statistics_announcement)

    result = statistics_announcements_history_list(statistics_announcement).first

    assert_includes(result, "Announcement cancelled")
    assert_not_includes(result, "linked_author")
    assert_includes(result, "User (removed)")
  end

  test "should render release dates when statistics announcement has multiple release dates, one with, one without a user" do
    user = build(:user)

    dates = [build(:statistics_announcement_date), build(:statistics_announcement_date, creator: user)]

    statistics_announcement = create(:statistics_announcement, statistics_announcement_dates: dates)

    result = statistics_announcements_history_list(statistics_announcement)

    assert_equal(2, result.length)
    assert_includes(result.first, "linked_author")
    assert_includes(result.second, "User (removed)")
  end
end
