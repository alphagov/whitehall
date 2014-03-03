require 'test_helper'

class ReleaseAnnouncementsControllerTest < ActionController::TestCase
  test "#index should assign all release announcements" do
    Frontend::ReleaseAnnouncementProvider.stubs(:all).returns(:some_release_announcements)
    get :index
    assert_equal :some_release_announcements, assigns(:release_announcements)
  end
end
