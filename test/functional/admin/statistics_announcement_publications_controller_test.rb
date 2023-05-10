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
    assert_select ".govuk-table" do
      assert_select "tr", count: 1
      assert_select "td", @statistics_publication.title
      assert_select "a[href=?]", admin_publication_path(@statistics_publication), text: "View"
      assert_select "a[href=?]", admin_statistics_announcement_publication_connect_path(@announcement, @statistics_publication), text: "Connect"
    end
  end

  test "GET :connect will add a document to a statistics announcement" do
    get :connect, params: { statistics_announcement_id: @announcement, publication_id: @statistics_publication }

    assert_equal @statistics_publication, @announcement.reload.publication

    assert_redirected_to admin_statistics_announcement_path(@announcement)
  end
end
