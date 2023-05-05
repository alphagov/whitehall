require "test_helper"

class Admin::StatisticsAnnouncementPublicationsControllerTest < ActionController::TestCase
  setup do
    @user = login_as_preview_design_system_user(:gds_editor)
    @announcement = create(:statistics_announcement)
  end

  should_be_an_admin_controller

  view_test "GET :new renders search bar" do
    get :index, params: { statistics_announcement_id: @announcement }

    assert_response :success
    assert_select "input[name='statistics_announcement[publication]']"
  end
end
