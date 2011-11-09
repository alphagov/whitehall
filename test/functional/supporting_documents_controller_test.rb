require "test_helper"

class SupportingDocumentsControllerTest < ActionController::TestCase
  test "index links to supporting documents" do
    policy = create(:published_policy)
    supporting_document = create(:supporting_document, title: "supporting-document-title", document: policy)
    get :index, policy_id: policy.document_identity
    path = policy_supporting_document_path(policy.document_identity, supporting_document)
    assert_select "#supporting_documents" do
      assert_select_object supporting_document do
        assert_select "a[href=#{path}]"
        assert_select ".title", text: "supporting-document-title"
      end
    end
  end

  test "index only shows supporting documents for the parent policy" do
    policy = create(:published_policy)
    other_supporting_document = create(:supporting_document)
    get :index, policy_id: policy.document_identity
    assert_select_object other_supporting_document, false
  end

  test "index doesn't display an empty list if there aren't any supporting documents" do
    policy = create(:published_policy)
    get :index, policy_id: policy.document_identity
    assert_select "#supporting_documents ul", count: 0
  end

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
