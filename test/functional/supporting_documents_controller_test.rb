require "test_helper"

class SupportingDocumentsControllerTest < ActionController::TestCase
  test "shows title and link to parent document" do
    document = create(:published_policy)
    supporting_document = create(:supporting_document, document: document)

    get :show, document_id: document.document_identity, id: supporting_document

    assert_select ".title", text: supporting_document.title
    assert_select "a[href='#{policy_path(document.document_identity)}']", text: "Back to '#{document.title}'"
  end

  test "shows the body using govspeak markup" do
    document = create(:published_policy)
    supporting_document = create(:supporting_document, document: document, body: "body-in-govspeak")
    Govspeak::Document.stubs(:to_html).with("body-in-govspeak").returns("body-in-html")

    get :show, document_id: document.document_identity, id: supporting_document

    assert_select ".body", text: "body-in-html"
  end

  test "doesn't show supporting document if parent isn't published" do
    document = create(:draft_policy)
    supporting_document = create(:supporting_document, document: document)

    get :show, document_id: document.document_identity, id: supporting_document

    assert_response :not_found
  end
end
