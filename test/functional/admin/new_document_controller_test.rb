require "test_helper"

class Admin::NewDocumentControllerTest < ActionController::TestCase
  setup do
    login_as :writer

    ConfigurableDocumentType.stubs(:find).returns(ConfigurableDocumentType.new({}))
  end

  view_test "GET #index renders the 'New Document' page with the header, all permitted radio selection options and inset text" do
    get :index

    assert_response :success
    assert_select "h1.gem-c-radio__heading-text", text: "New document"
    assert_select ".govuk-radios__item input[type=radio][name=new_document_options]", count: 11
    assert_select ".govuk-inset-text", text: "Check the content types guidance if you need more help in choosing a content type." do
      assert_select "a[href='#{Plek.website_root}/guidance/content-design/content-types']", text: "content types guidance"
    end
  end

  view_test "GET #index renders the Standard Edition option if the feature toggle is on" do
    @test_strategy ||= Flipflop::FeatureSet.current.test!
    @test_strategy.switch!(:configurable_document_types, true)

    get :index

    assert_response :success
    assert_select "input[type=radio][name=new_document_options][value=standard_edition]"

    @test_strategy.switch!(:configurable_document_types, false)
  end

  test "POST #new_document_options_redirect redirects legacy edition selections to their expected paths" do
    request_params = {
      "new_document_options": "consultation",
    }

    post :new_document_options_redirect, params: request_params

    assert_redirected_to new_admin_consultation_path
  end

  test "POST #new_document_options_redirect redirects edition selections with redirect overrides to their expected paths" do
    request_params = {
      "new_document_options": "news_article",
    }

    post :new_document_options_redirect, params: request_params

    assert_redirected_to choose_type_admin_standard_editions_path(group: "news_article")
  end

  test "POST #new_document_options_redirect redirects topical_event selection to the expected standard edition path" do
    request_params = {
      "new_document_options": "topical_event",
    }

    post :new_document_options_redirect, params: request_params

    assert_redirected_to new_admin_standard_edition_path(configurable_document_type: "topical_event")
  end

  test "when no radio buttons are selected a flash notice is shown and the user remains on the index page" do
    request_params = {
      new_document_options: "",
    }

    post :new_document_options_redirect, params: request_params

    assert_redirected_to admin_new_document_path
    assert_equal flash[:alert], "Please select a new document option"
  end
end
