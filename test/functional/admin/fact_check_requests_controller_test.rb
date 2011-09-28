require 'test_helper'

class Admin::FactCheckRequestsControllerTest < ActionController::TestCase
  setup do
    @edition = create(:draft_edition)
  end

  test 'users with a valid token should be able to access the policy' do
    fact_check_request = create(:fact_check_request, edition: @edition)
    get :edit, edition_id: @edition.to_param, id: fact_check_request.token
    assert_response :success
    assert_template 'admin/fact_check_requests/edit'
  end

  test 'users with invalid tokens should not be able to access the policy' do
    get :edit, edition_id: @edition.to_param, id: 'invalid-token'

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
end