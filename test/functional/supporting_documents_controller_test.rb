require "test_helper"

class SupportingDocumentsControllerTest < ActionController::TestCase
  test "shows title and link to parent document" do
    policy = create(:published_policy)
    supporting_document = create(:supporting_document, document: policy)

    get :show, policy_id: policy.document_identity, id: supporting_document

    assert_select ".title", text: supporting_document.title
    assert_select "a[href='#{policy_path(policy.document_identity)}']", text: "Back to '#{policy.title}'"
  end

  test "shows the body using govspeak markup" do
    policy = create(:published_policy)
    supporting_document = create(:supporting_document, document: policy, body: "body-in-govspeak")
    Govspeak::Document.stubs(:to_html).with("body-in-govspeak").returns("body-in-html")

    get :show, policy_id: policy.document_identity, id: supporting_document

    assert_select ".body", text: "body-in-html"
  end

  test "doesn't show supporting document if parent isn't published" do
    policy = create(:draft_policy)
    supporting_document = create(:supporting_document, document: policy)

    get :show, policy_id: policy.document_identity, id: supporting_document

    assert_response :not_found
  end
end
