require "test_helper"

class Admin::SupportingDocumentsControllerAuthenticationTest < ActionController::TestCase
  tests Admin::SupportingDocumentsController

  test "guests should not be able to access new" do
    document = create(:draft_policy)

    get :new, document_id: document.to_param

    assert_login_required
  end

  test "guests should not be able to access create" do
    document = create(:draft_policy)

    post :create, document_id: document.to_param, supporting_document: attributes_for(:supporting_document)

    assert_login_required
  end

  test "guests should not be able to access show" do
    document = create(:draft_policy)
    supporting_document = create(:supporting_document, document: document)

    get :show, document_id: document.to_param, id: supporting_document.to_param

    assert_login_required
  end
end

class Admin::SupportingDocumentsControllerTest < ActionController::TestCase
  setup do
    @user = login_as "George"
  end

  test "new form has title and body inputs" do
    document = create(:draft_policy)

    get :new, document_id: document.to_param

    assert_select "form[action='#{admin_document_supporting_documents_path(document)}']" do
      assert_select "input[name='supporting_document[title]'][type='text']"
      assert_select "textarea[name='supporting_document[body]']"
      assert_select "input[type='submit']"
    end
  end

  test "create adds supporting document" do
    document = create(:draft_policy)
    attributes = { title: "title", body: "body" }
    post :create, document_id: document.to_param, supporting_document: attributes

    assert supporting_document = document.supporting_documents.last
    assert_equal attributes[:title], supporting_document.title
    assert_equal attributes[:body], supporting_document.body
  end

  test "create should redirect to the document page" do
    document = create(:draft_policy)
    attributes = { title: "title", body: "body" }
    post :create, document_id: document.to_param, supporting_document: attributes

    assert_redirected_to admin_document_path(document)
    assert_equal flash[:notice], "The supporting document was added successfully"
  end

  test "create should render the form when attributes are invalid" do
    document = create(:draft_policy)
    invalid_attributes = { title: nil, body: "body" }
    post :create, document_id: document.to_param, supporting_document: invalid_attributes

    assert_template "new"
    assert_equal "There was a problem: Title can't be blank", flash[:alert]
  end

  test "shows the title and a link back to the parent" do
    document = create(:document)
    supporting_document = create(:supporting_document, document: document)

    get :show, document_id: document.to_param, id: supporting_document.to_param

    assert_select ".title", supporting_document.title
    assert_select "a[href='#{admin_document_path(document)}']", text: "Back to '#{document.title}'"
  end

  test "shows the body using govspeak markup" do
    supporting_document = create(:supporting_document, body: "govspeak-body-text")

    govspeak_document = mock("govspeak-document")
    govspeak_document.stubs(:to_html).returns("body-text-as-govspeak")
    Govspeak::Document.stubs(:new).with("govspeak-body-text").returns(govspeak_document)

    get :show, document_id: supporting_document.document.to_param, id: supporting_document.to_param

    assert_select ".body", text: "body-text-as-govspeak"
  end
end
