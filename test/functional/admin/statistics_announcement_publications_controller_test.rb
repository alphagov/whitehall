require "test_helper"

class Admin::StatisticsAnnouncementPublicationsControllerTest < ActionController::TestCase
  setup do
    @user = login_as_preview_design_system_user(:gds_editor)
    @announcement = create(:statistics_announcement)
    @statistics_publication = create(:published_statistics)
    @generic_publication = create(:publication)
    @search_string = "publication-title"
  end

  should_be_an_admin_controller

  view_test "GET :index with no search value renders search bar only" do
    get :index, params: { statistics_announcement_id: @announcement }

    assert_response :success
    assert_select ".govuk-label"
    assert_select "input[name='search']"
    refute_select ".govuk-table"
  end

  view_test "GET :index with search value renders search bar and list of statistical publications only" do
    get :index, params: { statistics_announcement_id: @announcement, search: "publication-title" }

    assert_response :success
    assert_select "input[name='search']"
    assert_select "p", "1 document"
    assert_select ".govuk-table"
    assert_select "td", @statistics_publication.title
  end
end
