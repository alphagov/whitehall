require "test_helper"

class Admin::StatisticsAnnouncementPublicationsControllerTest < ActionController::TestCase
  setup do
    @user = login_as(:gds_editor)
    @official_statistics_announcement = create(:statistics_announcement)
    @official_statistics_publication = create(:published_statistics)
    @title = "publication-title"
    @default_filter_params = {
      state: "active",
      type: "publication",
      subtypes: @official_statistics_announcement.publication_type,
      per_page: 15,
    }
  end

  should_be_an_admin_controller

  view_test "GET :index with no search value renders search bar only" do
    get :index, params: { statistics_announcement_id: @official_statistics_announcement }

    assert_response :success
    assert_select ".govuk-label"
    assert_select "input[name='title']"
    refute_select ".govuk-table"
  end

  test "GET :index with search value passes title and default params to filter" do
    default_filter_params_with_title = @default_filter_params.merge(title: @title)

    Admin::EditionFilter.expects(:new).with([@official_statistics_publication], @user, default_filter_params_with_title)

    get :index, params: { statistics_announcement_id: @official_statistics_announcement, title: @title }
  end

  view_test "GET :index with search value renders paginated results" do
    editions = []
    16.times { editions << @official_statistics_publication }

    stub_filter = stub_edition_filter({ editions:, options: { per_page: 15 } })
    Admin::EditionFilter.stubs(:new).returns(stub_filter)

    get :index, params: { statistics_announcement_id: @official_statistics_announcement, title: @title }

    assert_response :success
    assert_template :index
    assert_select "input[name='title']"
    assert_select ".govuk-heading-s", "16 documents"
    assert_select ".govuk-table" do
      assert_select "tr", count: 15
    end
    assert_select "nav.govuk-pagination"
  end

  test "GET :connect will add a document to a statistics announcement" do
    get :connect, params: { statistics_announcement_id: @official_statistics_announcement, publication_id: @official_statistics_publication }

    assert_equal @official_statistics_publication, @official_statistics_announcement.reload.publication
    assert_redirected_to admin_statistics_announcement_path(@official_statistics_announcement)
  end

  view_test "GET :connect will handle an error in adding not a statistics publication to statistics announcement" do
    @generic_publication = create(:publication)

    stub_filter = stub_edition_filter({ editions: [@official_statistics_publication], options: { per_page: 15 } })
    Admin::EditionFilter.stubs(:new).returns(stub_filter)

    get :connect, params: { statistics_announcement_id: @official_statistics_announcement, publication_id: @generic_publication, title: @title }

    assert_response :success
    has_search_results_table
    assert_select "ul.govuk-error-summary__list a[data-track-action='statistics announcement-error'][data-track-label=\"Publication type does not match: must be statistics\"]", text: "Publication type does not match: must be statistics"
  end

private

  def has_search_results_table
    assert_template :index
    assert_select "input[name='title']"
    assert_select ".govuk-heading-s", "1 document"
    assert_select ".govuk-table" do
      assert_select "tr", count: 1
      assert_select "td", @official_statistics_publication.title
      assert_select "a[href=?]", admin_publication_path(@official_statistics_publication), text: "View"
      assert_select "a[href=?]", admin_statistics_announcement_publication_connect_path(@official_statistics_announcement, @official_statistics_publication, title: @title), text: "Connect"
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
