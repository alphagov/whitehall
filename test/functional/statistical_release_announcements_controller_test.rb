require 'test_helper'

class StatisticalReleaseAnnouncementsControllerTest < ActionController::TestCase
  test "#index assign a ReleaseAnnouncementsFilter, populated with get params" do
    get :index, statistical_release_announcements_filter: { keywords: "wombats",
                                                            from_date: "2050-02-02",
                                                            to_date: "2055-01-01" }

    assert_equal "wombats", assigns(:filter).keywords
    assert_equal "2050-02-02", assigns(:filter).from_date
    assert_equal "2055-01-01", assigns(:filter).to_date
  end
end
