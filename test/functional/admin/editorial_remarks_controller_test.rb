require "test_helper"

class Admin::EditorialRemarksControllerTest < ActionController::TestCase
  setup do
    @logged_in_user = login_as :departmental_editor
  end

  should_be_an_admin_controller

  test "should render the document title and body to give context to the person rejecting" do
    document = create(:submitted_edition, title: "document-title", body: "document-body")
    get :new, document_id: document

    assert_select "#{record_css_selector(document)} .title", text: "document-title"
    assert_select "#{record_css_selector(document)} .body", text: "document-body"
  end

  test "should redirect to the list of documents that need work" do
    document = create(:submitted_edition)
    post :create, document_id: document, editorial_remark: { body: "editorial-remark-body" }
    assert_redirected_to admin_documents_path(state: :submitted)
  end

  test "should reject the document and create an editorial remark" do
    document = create(:submitted_edition)
    post :create, document_id: document, editorial_remark: { body: "editorial-remark-body" }

    document.reload
    assert document.rejected?
    assert_equal 1, document.editorial_remarks.length
    assert_equal @logged_in_user, document.editorial_remarks.first.author
    assert_equal "editorial-remark-body", document.editorial_remarks.first.body
  end

  test "should explain why the editorial remark couldn't be saved" do
    document = create(:submitted_edition)
    post :create, document_id: document, editorial_remark: { body: "" }
    assert_template "new"
    assert_select ".form-errors"
  end
end