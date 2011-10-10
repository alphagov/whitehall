require 'test_helper'

class Admin::FactCheckRequestsControllerTest < ActionController::TestCase
  setup do
    @edition = create(:draft_policy)
  end

  test "should render the content using govspeak markup" do
    @edition.update_attributes!(body: "body-text")
    fact_check_request = create(:fact_check_request, edition: @edition, comments: "comment")

    govspeak_document = mock("govspeak-document")
    govspeak_document.stubs(:to_html).returns("body-text-as-govspeak")
    Govspeak::Document.stubs(:new).with("body-text").returns(govspeak_document)

    get :show, edition_id: @edition.to_param, id: fact_check_request.token

    assert_select ".body", text: "body-text-as-govspeak"
  end

  test 'users with a valid token should be able to access the policy' do
    fact_check_request = create(:fact_check_request, edition: @edition)
    get :edit, edition_id: @edition.to_param, id: fact_check_request.token
    assert_response :success
    assert_template 'admin/fact_check_requests/edit'
  end

  test 'users with invalid tokens should not be able to access the policy' do
    get :edit, id: 'invalid-token', edition_id: @edition.to_param

    assert_response :not_found
  end

  test "should send an email when a fact check has been requested" do
    ActionMailer::Base.deliveries.clear
    post :create, edition_id: @edition.to_param, fact_check_request: {email_address: 'fact-checker@example.com'}
    assert_equal 1, ActionMailer::Base.deliveries.length
  end

  test "display an informational message when a fact check has been requested" do
    post :create, edition_id: @edition.to_param, fact_check_request: {email_address: 'fact-checker@example.com'}
    assert_equal "The policy has been sent to fact-checker@example.com", flash[:notice]
  end

  test "redirect to the edit form when a fact check has been requested" do
    post :create, edition_id: @edition.to_param, fact_check_request: {email_address: 'fact-checker@example.com'}
    assert_redirected_to edit_admin_edition_path(@edition)
  end

  test "should not send an email if the fact checker's email address is missing" do
    ActionMailer::Base.deliveries.clear
    post :create, edition_id: @edition.to_param, fact_check_request: {email_address: ''}
    assert_equal 0, ActionMailer::Base.deliveries.length
  end

  test "should display a warning if the fact checker's email address is missing" do
    post :create, edition_id: @edition.to_param, fact_check_request: {email_address: ''}
    assert_equal "There was a problem: Email address can't be blank", flash[:alert]
  end

  test "redirect to the edit form if the fact checker's email address is missing" do
    post :create, edition_id: @edition.to_param, fact_check_request: {email_address: ''}
    assert_redirected_to edit_admin_edition_path(@edition)
  end

  test "redirect to the show page when a fact check has been completed" do
    fact_check_request = create(:fact_check_request, edition: @edition)
    put :update, edition_id: @edition.to_param, id: fact_check_request.to_param,
        fact_check_request: {email_address: 'fact-checker@example.com', comments: 'looks fine to me'}
    assert_redirected_to admin_edition_fact_check_request_path(@edition, fact_check_request)
  end

end