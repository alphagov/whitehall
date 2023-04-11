require "test_helper"

class Admin::DashboardControllerTest < ActionController::TestCase
  setup do
    login_as_preview_design_system_user :writer

    organisation = create(:organisation, users: [@current_user])
    @draft_edition1 = create(:consultation, authors: [@current_user])
    @draft_edition2 = create(:consultation, authors: [@current_user])

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

    create(:edition_organisation, edition: @force_published_edition1, organisation:)
    create(:edition_organisation, edition: @force_published_edition2, organisation:)
  end

  should_be_an_admin_controller

  test "GET :index" do
    get :index

    assert_response :success
    assert_template :index
    assert_equal [@draft_edition2, @draft_edition1], assigns(:draft_documents)
    assert_equal [@force_published_edition2, @force_published_edition1], assigns(:force_published_documents)
  end
end
