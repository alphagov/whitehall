require 'test_helper'

class StatisticalReleaseAnnouncementsControllerTest < ActionController::TestCase
  test "#index should assign filtered release announcments" do
    Frontend::StatisticalReleaseAnnouncementProvider.stubs(:find_by).with({ keywords: "womble" }).returns(:some_filtered_release_announcements)
    get :index, statistical_release_announcements_filter: { keywords: "womble" }
    assert_equal :some_filtered_release_announcements, assigns(:release_announcements)
  end

  test "#index assign a ReleaseAnnouncementsFilter, populated with get params" do
    get :index, statistical_release_announcements_filter: { keywords: "wombats",
                                                            from_date: "2050-02-02",
                                                            to_date: "2055-01-01" }

    assert_equal "wombats", assigns(:filter).keywords
    assert_equal "2050-02-02", assigns(:filter).from_date
    assert_equal "2055-01-01", assigns(:filter).to_date
  end
end
