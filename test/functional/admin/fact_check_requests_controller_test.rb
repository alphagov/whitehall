require "test_helper"

class Admin::FactCheckRequestsControllerTest < ActionController::TestCase
  test "is an admin controller" do
    assert @controller.is_a?(Admin::BaseController), "the controller should have the behaviour of an Admin::BaseController"
  end

  test "should render the content using govspeak markup" do
    document = create(:document, body: "body-in-govspeak")
    fact_check_request = create(:fact_check_request, document: document, comments: "comment")
    Govspeak::Document.stubs(:to_html).with("body-in-govspeak").returns("body-in-html")

    get :show, id: fact_check_request.to_param

    assert_select ".body", text: "body-in-html"
  end

  test "should not display the document if it has been deleted" do
    document = create(:document, title: "deleted-policy-title", body: "deleted-policy-body")
    fact_check_request = create(:fact_check_request, document: document)
    document.delete!

    get :show, id: fact_check_request.to_param

    assert_select ".fact_check_request .apology", text: "We're sorry, but this document is no longer available for fact checking."
    assert_select ".title", text: "deleted-policy-title", count: 0
    assert_select ".body", text: "deleted-policy-body", count: 0
  end

  test "users with a valid.to_param should be able to access the policy" do
    fact_check_request = create(:fact_check_request)

    get :edit, id: fact_check_request.to_param

    assert_response :success
    assert_template "admin/fact_check_requests/edit"
  end

  test "users with invalid token should not be able to access the policy" do
    get :edit, id: "invalid-token"

    assert_response :not_found
  end

  test "it should not be possible to fact check a deleted document" do
    document = create(:document, title: "deleted-policy-title", body: "deleted-policy-body")
    fact_check_request = create(:fact_check_request, document: document)
    document.delete!

    get :edit, id: fact_check_request.to_param

    assert_select ".fact_check_request .apology", text: "We're sorry, but this document is no longer available for fact checking."
    assert_select "document_view .title", text: "deleted-policy-title", count: 0
    assert_select "document_view .body", text: "deleted-policy-body", count: 0
  end

  test "turn govspeak into nice markup when editing" do
    document = create(:document, body: "body-in-govspeak")
    fact_check_request = create(:fact_check_request, document: document)
    Govspeak::Document.stubs(:to_html).with("body-in-govspeak").returns("body-in-html")

    get :edit, id: fact_check_request.to_param

    assert_select ".body", text: "body-in-html"
  end

  test "adding comments to a policy" do
    policy = create(:policy)
    fact_check_request = create(:fact_check_request, document: policy)

    get :edit, id: fact_check_request.to_param

    assert_response :success
  end

  test "adding comments to a publication" do
    publication = create(:publication)
    fact_check_request = create(:fact_check_request, document: publication)

    get :edit, id: fact_check_request.to_param

    assert_response :success
  end

  test "should display any additional instructions to the fact checker" do
    fact_check_request = create(:fact_check_request, instructions: "Please concentrate on the content")

    get :edit, id: fact_check_request.to_param

    assert_select "#fact_check_request_instructions", text: /Please concentrate on the content/
  end

  test "should not display the extra instructions section" do
    fact_check_request = create(:fact_check_request, instructions: "")

    get :edit, id: fact_check_request.to_param

    assert_select "#fact_check_request_instructions", count: 0
  end

  test "should not display the supporting documents section" do
    policy = create(:policy, supporting_documents: [])
    fact_check_request = create(:fact_check_request, document: policy)

    get :edit, id: fact_check_request.to_param

    assert_select "#supporting_documents", count: 0
  end

  test "should display the supporting documents section" do
    policy = create(:policy, supporting_documents: [create(:supporting_document, title: "Blah!")])
    fact_check_request = create(:fact_check_request, document: policy)

    get :edit, id: fact_check_request.to_param

    assert_select "#supporting_documents .title", "Blah!"
  end

  test "save the fact checkers comment" do
    fact_check_request = create(:fact_check_request)
    attributes = attributes_for(:fact_check_request, comments: "looks fine to me")

    put :update, id: fact_check_request, fact_check_request: attributes

    fact_check_request.reload
    assert_equal "looks fine to me", fact_check_request.comments
  end

  test "redirect to the show page when a fact check has been completed" do
    fact_check_request = create(:fact_check_request)
    attributes = attributes_for(:fact_check_request, comments: "looks fine to me")

    put :update, id: fact_check_request, fact_check_request: attributes

    assert_redirected_to admin_fact_check_request_path(fact_check_request)
  end

  test "display an apology if comments are submitted for a deleted document" do
    document = create(:document)
    fact_check_request = create(:fact_check_request, document: document)
    document.delete!
    attributes = attributes_for(:fact_check_request, comments: "looks fine to me")

    put :update, id: fact_check_request, fact_check_request: attributes

    assert_select ".fact_check_request .apology", text: "We're sorry, but this document is no longer available for fact checking."
  end
end

class Admin::CreatingFactCheckRequestsControllerTest < ActionController::TestCase
  tests Admin::FactCheckRequestsController

  setup do
    ActionMailer::Base.deliveries.clear
    @attributes = attributes_for(:fact_check_request)
    @document = create(:draft_policy)
    @requestor = login_as(:policy_writer)
  end

  teardown do
    request.host = "test.host"
    request.env["HTTPS"] = nil
  end

  test "should create a fact check request" do
    @attributes.merge!(email_address: "fact-checker@example.com")

    post :create, document_id: @document.id, fact_check_request: @attributes

    assert fact_check_request = @document.fact_check_requests.last
    assert_equal "fact-checker@example.com", fact_check_request.email_address
    assert_equal @requestor, fact_check_request.requestor
  end

  test "should send an email when a fact check has been requested" do
    post :create, document_id: @document.id, fact_check_request: @attributes

    assert_equal 1, ActionMailer::Base.deliveries.length
  end

  test "uses host from request in email urls" do
    request.host = "whitehall.example.com"

    post :create, document_id: @document.id, fact_check_request: @attributes

    assert_last_email_body_contains("http://whitehall.example.com/")
  end

  test "uses protocol from request in email urls" do
    request.env["HTTPS"] = "on"
    request.host = "whitehall.example.com"

    post :create, document_id: @document.id, fact_check_request: @attributes

    assert_last_email_body_contains("https://whitehall.example.com/")
  end

  test "uses port from request in email urls" do
    request.host = "whitehall.example.com:8182"

    post :create, document_id: @document.id, fact_check_request: @attributes

    assert_last_email_body_contains("http://whitehall.example.com:8182/")
  end

  test "display an informational message when a fact check has been requested" do
    post :create, document_id: @document.id, fact_check_request: @attributes

    assert_equal "The policy has been sent to fact-checker@example.com", flash[:notice]
  end

  test "redirect back to the document preview when a fact check has been requested" do
    post :create, document_id: @document.id, fact_check_request: @attributes

    assert_redirected_to admin_policy_path(@document)
  end

  test "should not send an email if the fact checker's email address is missing" do
    @attributes.merge!(email_address: "")
    ActionMailer::Base.deliveries.clear

    post :create, document_id: @document.id, fact_check_request: @attributes

    assert_equal 0, ActionMailer::Base.deliveries.length
  end

  test "should display a warning if the fact checker's email address is missing" do
    @attributes.merge!(email_address: "")

    post :create, document_id: @document.id, fact_check_request: @attributes

    assert_equal "There was a problem: Email address can't be blank", flash[:alert]
  end

  test "redirect back to the document preview if the fact checker's email address is missing" do
    @attributes.merge!(email_address: "")

    post :create, document_id: @document.id, fact_check_request: @attributes

    assert_redirected_to admin_policy_path(@document)
  end

  test "should reject invalid email addresses" do
    @attributes.merge!(email_address: "not-an-email")

    post :create, document_id: @document.id, fact_check_request: @attributes

    assert_equal "There was a problem: Email address does not appear to be valid", flash[:alert]
  end

  test "should display an apology if requesting a fact check for a document that has been deleted" do
    @document.delete!

    post :create, document_id: @document.id, fact_check_request: @attributes

    assert_select ".fact_check_request .apology", text: "We're sorry, but this document is no longer available for fact checking."
  end

  private

  def assert_last_email_body_contains(text)
    assert_match Regexp.new(Regexp.escape(text)), ActionMailer::Base.deliveries.last.body.to_s
  end

end
