require "test_helper"

class Admin::LandingPagesControllerTest < ActionController::TestCase
  setup do
    @organisation = create(:organisation)
    login_as(:gds_admin, @organisation)
  end

  should_be_an_admin_controller

  test "GET :new prepares an unsaved instance" do
    get :new

    assert assigns(:edition).is_a? LandingPage
    assert_not assigns(:edition).persisted?
    assert_response :success
    assert_template "new"
  end

  test "POST :create saves a new instance with the supplied valid params" do
    landing_page_attrs = attributes_for(:landing_page, title: "Hello there", summary: "Landing page summary", body: "blocks:")
                             .merge(
                               lead_organisation_ids: [@organisation.id],
                               document_attributes: {
                                 slug: "/landing-page/test",
                               },
                             )

    post :create, params: { edition: landing_page_attrs }

    assert assigns(:edition).persisted?
    assert_equal "Hello there", assigns(:edition).title
    assert_equal "Landing page summary", assigns(:edition).summary
    assert_equal "blocks:", assigns(:edition).body
    assert_equal "/landing-page/test", assigns(:edition).base_path
    assert_redirected_to admin_landing_page_path(assigns(:edition))
  end

  test "POST :create doesn't save the new instance when the supplied params are invalid" do
    attrs = attributes_for(:landing_page, title: "", lead_organisation_ids: [@organisation.id])

    post :create, params: { edition: attrs }

    assert_not assigns(:edition).persisted?
    assert_response :success
    assert_template "new"
  end

  test "GET :edit fetches the supplied instance" do
    page = create(:landing_page, organisations: [@organisation])

    get :edit, params: { id: page }

    assert_equal page, assigns(:edition)
    assert_response :success
    assert_template "edit"
  end

  test "PUT :update changes the supplied instance with the supplied params" do
    attrs = attributes_for(:landing_page, title: "Hello there")
    page = create(:landing_page, organisations: [@organisation], title: "Goodbye")

    post :update, params: {
      id: page,
      edition: attrs,
    }

    assert_equal page, assigns(:edition)
    assert_equal "Hello there", page.reload.title
    assert_redirected_to admin_landing_page_path(page)
  end

  test "PUT :update doesn't save the new instance when the supplied params are invalid" do
    attrs = attributes_for(:landing_page, title: "")
    page = create(:landing_page, organisations: [@organisation], title: "Goodbye")

    post :update, params: { id: page, edition: attrs }

    assert_equal page, assigns(:edition)
    assert_not_equal "", page.reload.title
    assert_equal "", assigns(:edition).title
    assert_response :success
    assert_template "edit"
  end
end
