require "test_helper"

class Admin::FactCheckRequestsControllerTest < ActionController::TestCase
  should_be_an_admin_controller

  setup do
    login_as_admin
  end

  view_test "should render the content using govspeak markup" do
    edition = create(:edition, body: "body-in-govspeak")
    fact_check_request = create(:fact_check_request, edition: edition, comments: "comment")
    govspeak_transformation_fixture "body-in-govspeak" => "body-in-html" do
      get :show, id: fact_check_request
    end

    assert_select ".body", text: "body-in-html"
  end

  view_test "should not display the edition if it has been deleted" do
    edition = create(:edition, title: "deleted-policy-title", body: "deleted-policy-body")
    fact_check_request = create(:fact_check_request, edition: edition)
    edition.delete!

    get :show, id: fact_check_request

    assert_select ".fact_check_request .apology", text: "We're sorry, but this document is no longer available for fact checking."
    refute_select ".title", text: "deleted-policy-title"
    refute_select ".body", text: "deleted-policy-body"
  end

  test "users with a valid.to_param should be able to access the policy" do
    fact_check_request = create(:fact_check_request)

    get :edit, id: fact_check_request

    assert_response :success
    assert_template "admin/fact_check_requests/edit"
  end

  test "users with invalid token should not be able to access the policy" do
    get :edit, id: "invalid-token"

    assert_response :not_found
  end

  view_test "it should not be possible to fact check a deleted edition" do
    edition = create(:edition, title: "deleted-policy-title", body: "deleted-policy-body")
    fact_check_request = create(:fact_check_request, edition: edition)
    edition.delete!

    get :edit, id: fact_check_request

    assert_select ".fact_check_request .apology", text: "We're sorry, but this document is no longer available for fact checking."
    refute_select ".document .title", text: "deleted-policy-title"
    refute_select ".document .body", text: "deleted-policy-body"
  end

  view_test "turn govspeak into nice markup when editing" do
    edition = create(:edition, body: "body-in-govspeak")
    fact_check_request = create(:fact_check_request, edition: edition)
    govspeak_transformation_fixture "body-in-govspeak" => "body-in-html" do
      get :edit, id: fact_check_request
    end

    assert_select ".body", text: "body-in-html"
  end

  test "adding comments to a policy" do
    policy = create(:policy)
    fact_check_request = create(:fact_check_request, edition: policy)

    get :edit, id: fact_check_request

    assert_response :success
  end

  test "adding comments to a publication" do
    publication = create(:publication)
    fact_check_request = create(:fact_check_request, edition: publication)

    get :edit, id: fact_check_request

    assert_response :success
  end

  view_test "should display any additional instructions to the fact checker" do
    fact_check_request = create(:fact_check_request, instructions: "Please concentrate on the content")

    get :edit, id: fact_check_request

    assert_select "#fact_check_request_instructions", text: /Please concentrate on the content/
  end

  view_test "should not display the extra instructions section" do
    fact_check_request = create(:fact_check_request, instructions: "")

    get :edit, id: fact_check_request

    refute_select "#fact_check_request_instructions"
  end

  test "save the fact checkers comment" do
    fact_check_request = create(:fact_check_request)
    attributes = attributes_for(:fact_check_request, comments: "looks fine to me")

    put :update, id: fact_check_request, fact_check_request: attributes

    fact_check_request.reload
    assert_equal "looks fine to me", fact_check_request.comments
  end

  test "notify a requestor with an email address that the fact checker has added a comment" do
    requestor = create(:fact_check_requestor, email: "fact-check-requestor@example.com")
    fact_check_request = create(:fact_check_request, requestor: requestor)
    attributes = attributes_for(:fact_check_request, comments: "looks fine to me")
    ActionMailer::Base.deliveries.clear

    put :update, id: fact_check_request, fact_check_request: attributes

    assert_equal 1, ActionMailer::Base.deliveries.length
  end

  test "do not notify a requestor without an email address that the fact checker has added a comment" do
    requestor = create(:fact_check_requestor, email: nil)
    fact_check_request = create(:fact_check_request, requestor: requestor)
    attributes = attributes_for(:fact_check_request, comments: "looks fine to me")
    ActionMailer::Base.deliveries.clear

    put :update, id: fact_check_request, fact_check_request: attributes

    assert_equal 0, ActionMailer::Base.deliveries.length
  end

  test "redirect to the show page when a fact check has been completed" do
    fact_check_request = create(:fact_check_request)
    attributes = attributes_for(:fact_check_request, comments: "looks fine to me")

    put :update, id: fact_check_request, fact_check_request: attributes

    assert_redirected_to admin_fact_check_request_path(fact_check_request)
  end

  view_test "display an apology if comments are submitted for a deleted edition" do
    edition = create(:edition)
    fact_check_request = create(:fact_check_request, edition: edition)
    edition.delete!
    attributes = attributes_for(:fact_check_request, comments: "looks fine to me")

    put :update, id: fact_check_request, fact_check_request: attributes

    assert_select ".fact_check_request .apology", text: "We're sorry, but this document is no longer available for fact checking."
  end
end

class Admin::CreatingFactCheckRequestsControllerTest < ActionController::TestCase
  tests Admin::FactCheckRequestsController

  setup do
    @attributes = attributes_for(:fact_check_request)
    @edition = create(:draft_policy)
    @requestor = login_as(:policy_writer)
    ActionMailer::Base.deliveries.clear
  end

  teardown do
    request.host = "test.host"
    request.env["HTTPS"] = nil
  end

  test "should create a fact check request" do
    @attributes.merge!(email_address: "fact-checker@example.com")
    post :create, edition_id: @edition.id, fact_check_request: @attributes

    assert fact_check_request = @edition.fact_check_requests.last
    assert_equal "fact-checker@example.com", fact_check_request.email_address
    assert_equal @requestor, fact_check_request.requestor
  end

  test "should prevent creation of a fact check request if edition is not accessible to the current user" do
    protected_edition = create(:draft_publication, :access_limited)
    post :create, edition_id: protected_edition.id, fact_check_request: @attributes

    assert_response :forbidden
  end

  test "should send an email when a fact check has been requested" do
    post :create, edition_id: @edition.id, fact_check_request: @attributes

    assert_equal 1, ActionMailer::Base.deliveries.length
  end

  test "uses host from request in email urls" do
    request.host = "whitehall.example.com"
    post :create, edition_id: @edition.id, fact_check_request: @attributes

    assert_last_email_body_contains("http://whitehall.example.com/")
  end

  test "uses protocol from request in email urls" do
    request.env["HTTPS"] = "on"
    request.host = "whitehall.example.com"
    post :create, edition_id: @edition.id, fact_check_request: @attributes

    assert_last_email_body_contains("https://whitehall.example.com/")
  end

  test "uses port from request in email urls" do
    request.host = "whitehall.example.com:8182"
    post :create, edition_id: @edition.id, fact_check_request: @attributes

    assert_last_email_body_contains("http://whitehall.example.com:8182/")
  end

  test "display an informational message when a fact check has been requested" do
    post :create, edition_id: @edition.id, fact_check_request: @attributes

    assert_equal "The document has been sent to fact-checker@example.com", flash[:notice]
  end

  test "redirect back to the edition preview when a fact check has been requested" do
    post :create, edition_id: @edition.id, fact_check_request: @attributes

    assert_redirected_to admin_policy_path(@edition)
  end

  test "should not send an email if the fact checker's email address is missing" do
    @attributes.merge!(email_address: "")
    post :create, edition_id: @edition.id, fact_check_request: @attributes

    assert_equal 0, ActionMailer::Base.deliveries.length
  end

  test "should display a warning if the fact checker's email address is missing" do
    @attributes.merge!(email_address: "")
    post :create, edition_id: @edition.id, fact_check_request: @attributes

    assert_equal "There was a problem: Email address can't be blank", flash[:alert]
  end

  test "redirect back to the edition preview if the fact checker's email address is missing" do
    @attributes.merge!(email_address: "")
    post :create, edition_id: @edition.id, fact_check_request: @attributes

    assert_redirected_to admin_policy_path(@edition)
  end

  test "should reject invalid email addresses" do
    @attributes.merge!(email_address: "not-an-email")
    post :create, edition_id: @edition.id, fact_check_request: @attributes

    assert_equal "There was a problem: Email address does not appear to be valid", flash[:alert]
  end

  view_test "should display an apology if requesting a fact check for an edition that has been deleted" do
    @edition.delete!
    post :create, edition_id: @edition.id, fact_check_request: @attributes

    assert_select ".fact_check_request .apology", text: "We're sorry, but this document is no longer available for fact checking."
  end

  private

  def assert_last_email_body_contains(text)
    assert_match Regexp.new(Regexp.escape(text)), ActionMailer::Base.deliveries.last.body.to_s
  end
end
