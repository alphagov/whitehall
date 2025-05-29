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

  test "POST #new_document_options_redirect redirects each radio buttons to their expected paths" do
    redirect_options.each do |selected_option, expected_path|
      request_params = {
        "new_document_options": selected_option,
      }

      post :new_document_options_redirect, params: request_params

      assert_redirected_to send(expected_path)
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
    Document::View::New.types_for(@current_user).map { |type| type.name.underscore }
  end

  def assert_select_radio_button(value)
    assert_select ".govuk-radios__item input[type=radio][name=new_document_options][value=#{value}]", count: 1
  end

  def redirect_options
    radio_button_values.index_with { |key| "new_admin_#{key}_path" }
  end
end
