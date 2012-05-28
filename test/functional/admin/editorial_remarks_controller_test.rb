require "test_helper"

class Admin::EditorialRemarksControllerTest < ActionController::TestCase
  setup do
    @logged_in_user = login_as :departmental_editor
  end

  should_be_an_admin_controller

  test "should render the edition title and body to give context to the person rejecting" do
    edition = create(:submitted_edition, title: "edition-title", body: "edition-body")
    get :new, document_id: edition

    assert_select "#{record_css_selector(edition)} .title", text: "edition-title"
    assert_select "#{record_css_selector(edition)} .body", text: "edition-body"
  end

  test "should redirect to the list of editions that need work" do
    edition = create(:submitted_edition)
    post :create, document_id: edition, editorial_remark: { body: "editorial-remark-body" }
    assert_redirected_to admin_documents_path(state: :submitted)
  end

  test "should create an editorial remark" do
    edition = create(:submitted_edition)
    post :create, document_id: edition, editorial_remark: { body: "editorial-remark-body" }

    edition.reload
    assert_equal 1, edition.editorial_remarks.length
    assert_equal @logged_in_user, edition.editorial_remarks.first.author
    assert_equal "editorial-remark-body", edition.editorial_remarks.first.body
  end

  test "should explain why the editorial remark couldn't be saved" do
    edition = create(:submitted_edition)
    post :create, document_id: edition, editorial_remark: { body: "" }
    assert_template "new"
    assert_select ".form-errors"
  end
end