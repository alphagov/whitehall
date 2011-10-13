require "test_helper"

class SupportingDocumentsControllerTest < ActionController::TestCase
  test "shows title and link to parent document" do
    document = create(:published_policy)
    supporting_document = create(:supporting_document, document: document)

    get :show, document_id: document.document_identity, id: supporting_document

    assert_select ".title", text: supporting_document.title
    assert_select "a[href='#{document_path(document)}']", text: "Back to '#{document.title}'"
  end

  test "shows the body using govspeak markup" do
    document = create(:published_policy)
    supporting_document = create(:supporting_document, document: document, body: "govspeak-body-text")

    govspeak_document = mock("govspeak-document")
    govspeak_document.stubs(:to_html).returns("body-text-as-govspeak")
    Govspeak::Document.stubs(:new).with("govspeak-body-text").returns(govspeak_document)

    get :show, document_id: document.document_identity, id: supporting_document

    assert_select ".body", text: "body-text-as-govspeak"
  end

  test "doesn't show supporting document if parent isn't published" do
    document = create(:draft_policy)
    supporting_document = create(:supporting_document, document: document)

    get :show, document_id: document.document_identity, id: supporting_document

    assert_response :not_found
  end
end
