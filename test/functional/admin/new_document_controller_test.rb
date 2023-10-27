require "test_helper"

class Admin::NewDocumentControllerTest < ActionController::TestCase
  setup do
    login_as_preview_design_system_user :writer
  end

  view_test "GET #index renders the 'New Document' page with the header, all relevant radio selection options and inset text" do
    get :index

    assert_response :success
    assert_select "h1.gem-c-radio__heading-text", text: "New document"
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

  test "POST #new_document_options_redirect redirects each radio buttons to their expected paths" do
    redirect_options.each do |selected_option, expected_path|
      request_params = {
        "new_document_options": selected_option,
      }

      post :new_document_options_redirect, params: request_params

      assert_redirected_to expected_path
    end
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

  def redirect_options
    {
      "call-for-evidence": new_admin_call_for_evidence_path,
      "case-study": new_admin_case_study_path,
      "consultation": new_admin_consultation_path,
      "detailed-guide": new_admin_detailed_guide_path,
      "document-collection": new_admin_document_collection_path,
      "fatality-notice": new_admin_fatality_notice_path,
      "news-article": new_admin_news_article_path,
      "publication": new_admin_publication_path,
      "speech": new_admin_speech_path,
      "statistical-data-set": new_admin_statistical_data_set_path,
    }
  end
end
