require "test_helper"

class Admin::StatisticsAnnouncementPublicationsControllerTest < ActionController::TestCase
  setup do
    @user = login_as_preview_design_system_user(:gds_editor)
    @announcement = create(:statistics_announcement)
    @statistics_publication = create(:published_statistics)
    @generic_publication = create(:publication)
    @search = "publication-title"
  end

  should_be_an_admin_controller

  view_test "GET :index with no search value renders search bar only" do
    get :index, params: { statistics_announcement_id: @announcement }

    assert_response :success
    assert_select ".govuk-label"
    assert_select "input[name='search']"
    refute_select ".govuk-table"
  end

  test "GET :index will only return statistical publications" do
    Admin::EditionFilter.expects(:new).with([@statistics_publication], anything, anything)

    get :index, params: { statistics_announcement_id: @announcement, search: @search }
  end

  test "GET :index will filter by title containing search param" do
    create(:published_statistics, title: "something else")

    Admin::EditionFilter.expects(:new).with([@statistics_publication], anything, anything)

    get :index, params: { statistics_announcement_id: @announcement, search: @search }
  end

  view_test "GET :index with search value renders paginated results" do
    editions = []
    16.times { editions << @statistics_publication }

    stub_filter = stub_edition_filter({ editions:, options: { per_page: 15 } })
    Admin::EditionFilter.stubs(:new).returns(stub_filter)

    get :index, params: { statistics_announcement_id: @announcement, search: @search }

    assert_response :success
    assert_template :index
    assert_select "input[name='search']"
    assert_select ".govuk-heading-s", "16 documents"
    assert_select ".govuk-table" do
      assert_select "tr", count: 15
    end
    assert_select "nav.govuk-pagination"
  end

  test "GET :connect will add a document to a statistics announcement" do
    get :connect, params: { statistics_announcement_id: @announcement, publication_id: @statistics_publication }

    assert_equal @statistics_publication, @announcement.reload.publication
    assert_redirected_to admin_statistics_announcement_path(@announcement)
  end

  view_test "GET :connect will handle an error in adding not a statistics publication to statistics announcement" do
    stub_filter = stub_edition_filter({ editions: [@statistics_publication], options: { per_page: 15 } })
    Admin::EditionFilter.stubs(:new).returns(stub_filter)

    get :connect, params: { statistics_announcement_id: @announcement, publication_id: @generic_publication, search: @search }

    assert_response :success
    has_search_results_table
    assert_select "ul.govuk-error-summary__list a[data-track-action='statistics announcement-error'][data-track-label=\"Publication type does not match: must be statistics\"]", text: "Publication type does not match: must be statistics"
  end

private

  def has_search_results_table
    assert_template :index
    assert_select "input[name='search']"
    assert_select ".govuk-heading-s", "1 document"
    assert_select ".govuk-table" do
      assert_select "tr", count: 1
      assert_select "td", @statistics_publication.title
      assert_select "a[href=?]", admin_publication_path(@statistics_publication), text: "View"
      assert_select "a[href=?]", admin_statistics_announcement_publication_connect_path(@announcement, @statistics_publication, search: @search), text: "Connect"
    end
  end

  def stub_edition_filter(attributes = {})
    default_attributes = {
      editions: Kaminari.paginate_array(attributes[:editions] || [], limit: attributes[:options][:per_page]).page(1),
      page_title: "",
      edition_state: "",
      valid?: true,
      options: {},
      hide_type: false,
    }
    stub("edition filter", default_attributes.merge(attributes.except(:editions)))
  end
end
