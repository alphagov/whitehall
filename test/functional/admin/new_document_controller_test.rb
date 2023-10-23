require "test_helper"

class Admin::NewDocumentControllerTest < ActionController::TestCase
  setup do
    login_as_preview_design_system_user :writer
  end

  view_test "GET #index renders the 'New Document' page with the header, all relevant radio selection options and inset text" do
    get :index

    assert_response :success
    assert_select "h1.govuk-heading-xl", text: "New document"

    radio_button_values.each do |value|
      assert_select_radio_button(value)
    end

    assert_select ".govuk-inset-text", text: "Check the content types guidance if you need more help in choosing a content type."
  end

  test "access to the New document index page is forbidden for users without design system permissions" do
    login_as :writer
    get :index
    assert_response :forbidden
  end

  test "POST #new_document_options_redirect redirects to #call-for-evidence if search option passed is call-for-evidence" do
    request_params = {
      "new_document_options": "call-for-evidence",
    }
    post :new_document_options_redirect, params: request_params
    assert_redirected_to new_admin_call_for_evidence_path
  end

  test "when no radio buttons are selected a flash notice is shown and the user remains on the index page" do
    request_params = {
      new_document_options: "",
    }

    post :new_document_options_redirect, params: request_params
    assert_redirected_to admin_new_document_path
    assert_equal flash[:alert], "Please select a new document option"
  end

private

  def radio_button_values
    %w[call-for-evidence case-study consultation detailed-guide document-collection fatality-notice news-article publication speech statistical-data-set]
  end

  def assert_select_radio_button(value)
    assert_select ".govuk-radios__item input[type=radio][name=new_document_options][value=#{value}]", count: 1
  end
end
