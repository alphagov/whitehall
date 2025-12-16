require "test_helper"

class Admin::DashboardControllerTest < ActionController::TestCase
  setup do
    login_as :writer
    setup_configurable_document_type("draft_standard_edition", { "title" => "Draft Document" })
    setup_configurable_document_type("force_published_standard_edition", { "title" => "Force Published Document" })

    organisation = create(:organisation, users: [@current_user])
    @draft_edition1 = create(:consultation, authors: [@current_user])
    @draft_edition2 = create(:consultation, authors: [@current_user])
    @draft_standard_edition = create(
      :draft_standard_edition,
      authors: [@current_user],
      configurable_document_type: :draft_standard_edition,
    )

    @force_published_edition1 = build(
      :consultation,
      :published,
      force_published: true,
    )
    @force_published_edition2 = build(
      :consultation,
      :published,
      force_published: true,
    )
    @force_published_standard_edition = build(
      :force_published_standard_edition,
      authors: [@current_user],
      configurable_document_type: :force_published_standard_edition,
    )

    create(:edition_organisation, edition: @force_published_edition1, organisation:)
    create(:edition_organisation, edition: @force_published_edition2, organisation:)
    create(:edition_organisation, edition: @force_published_standard_edition, organisation:)
  end

  should_be_an_admin_controller

  test "GET :index" do
    get :index

    assert_response :success
    assert_template :index
    assert_equal [@draft_standard_edition, @draft_edition2, @draft_edition1], assigns(:draft_documents)
    assert_equal [@force_published_standard_edition, @force_published_edition2, @force_published_edition1], assigns(:force_published_documents)
  end

  view_test "GET shows draft standard edition documents with the correct type" do
    get :index

    assert_dom ".app-view-dashboard-index__table:nth-of-type(1) td", "Draft Document"
    refute_dom ".app-view-dashboard-index__table:nth-of-type(1) td", /Standard Edition/i
    refute_dom ".app-view-dashboard-index__table:nth-of-type(1) td", /Force Published Document/i
  end

  view_test "GET shows force published standard edition documents with the correct type" do
    get :index

    assert_dom ".app-view-dashboard-index__table:nth-of-type(2) td", "Force Published Document"
    refute_dom ".app-view-dashboard-index__table:nth-of-type(2) td", /Standard Edition/i
    refute_dom ".app-view-dashboard-index__table:nth-of-type(2) td", /Draft Document/
  end
end
