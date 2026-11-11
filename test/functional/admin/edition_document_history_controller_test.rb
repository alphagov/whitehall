require "test_helper"

class Admin::EditionDocumentHistoryControllerTest < ActionController::TestCase
  setup do
    @my_organisation = create(:organisation)
    @other_organisation = create(:organisation)
    login_as create(:writer, organisation: @my_organisation)
  end

  should_be_an_admin_controller

  test "GET :index renders the document history of an edition the user can see" do
    edition = create(:draft_publication, organisations: [@my_organisation])

    get :index, params: { id: edition }

    assert_response :success
  end

  test "GET :index is forbidden for an access-limited edition the user cannot see" do
    inaccessible = create(:draft_publication, :access_limited_by_organisations, organisations: [@other_organisation])
    create(:editorial_remark, edition: inaccessible, body: "Secret remark")

    get :index, params: { id: inaccessible }

    assert_response :forbidden
    assert_no_match(/Secret remark/, response.body)
  end
end
