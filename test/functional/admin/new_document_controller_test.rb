require "test_helper"

class Admin::NewDocumentControllerTest < ActionController::TestCase
  setup do
    login_as :gds_editor
  end

  view_test "GET #index renders the 'New Document' page with the header, all relevant radio selection options and inset text" do
    get :index

    assert_response :success
    assert_select "h1.gem-c-radio__heading-text", text: "New document"
    radio_button_values.each do |value|
      assert_select_radio_button(value)
    end
    assert_select ".govuk-inset-text", text: "Check the content types guidance if you need more help in choosing a content type." do
      assert_select "a[href='#{Plek.website_root}/guidance/content-design/content-types']", text: "content types guidance"
    end
  end

  view_test "GET #index renders Fatality Notice radio button when the user has GDS Editor permission and organisation is GDS" do
    gds_organisation = create(:organisation, name: "government-digital-service")
    login_as(:gds_editor, gds_organisation)

    get :index

    assert_select ".govuk-radios__item input[type=radio][name=new_document_options][value=fatality_notice]", count: 1
  end

  view_test "GET #index does not render Fatality Notice radio button when the user does not have GDS Editor permission and their organisation is GDS" do
    gds_organisation = create(:organisation, name: "government-digital-service")
    login_as(:writer, gds_organisation)

    get :index

    refute_select ".govuk-radios__item input[type=radio][name=new_document_options][value=fatality_notice]"
  end

  view_test "GET #index does not render Fatality Notice radio button when the user does not have GDS Editor permission and their organisation is not GDS" do
    other_organisation = create(:organisation, name: "cabinet-minister")
    login_as(:writer, other_organisation)

    get :index

    refute_select ".govuk-radios__item input[type=radio][name=new_document_options][value=fatality_notice]"
  end

  view_test "GET #index renders Fatality Notice radio button when the user's organisation is Ministry of Defence" do
    mod_organisation = create(:organisation, name: "ministry-of-defence", handles_fatalities: true)

    login_as(:writer, mod_organisation)

    get :index

    assert_select ".govuk-radios__item input[type=radio][name=new_document_options][value=fatality_notice]", count: 1
  end

  view_test "GET #index renders Worldwide Organisation Edition when the editionable_worldwide_organisations feature flag is enabled" do
    get :index

    assert_select ".govuk-radios__item input[type=radio][name=new_document_options][value=editionable_worldwide_organisation]", count: 1
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
    %w[call_for_evidence case_study consultation detailed_guide document_collection fatality_notice news_article publication speech statistical_data_set]
  end

  def assert_select_radio_button(value)
    assert_select ".govuk-radios__item input[type=radio][name=new_document_options][value=#{value}]", count: 1
  end

  def redirect_options
    {
      "call_for_evidence": new_admin_call_for_evidence_path,
      "case_study": new_admin_case_study_path,
      "consultation": new_admin_consultation_path,
      "detailed_guide": new_admin_detailed_guide_path,
      "document_collection": new_admin_document_collection_path,
      "fatality_notice": new_admin_fatality_notice_path,
      "news_article": new_admin_news_article_path,
      "publication": new_admin_publication_path,
      "speech": new_admin_speech_path,
      "statistical_data_set": new_admin_statistical_data_set_path,
      "editionable_worldwide_organisation": new_admin_editionable_worldwide_organisation_path,
    }
  end
end
