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

  view_test "GET #index renders with the real configurable document types" do
    ConfigurableDocumentType.unstub(:find)
    ConfigurableDocumentType.setup_test_types(nil)

    get :index

    assert_response :success
  end

  view_test "GET #index with a `parent_edition_id` shows the Child Of Banner for the parent edition" do
    ConfigurableDocumentType.unstub(:find)
    required_document_types = build_configurable_document_type("test_type")
      .merge(build_configurable_document_type("mini_site_landing"))
      .merge(build_configurable_document_type("topical_event"))
      .merge(build_configurable_document_type("case_study"))

    ConfigurableDocumentType.setup_test_types(required_document_types)
    parent_edition = create(:standard_edition, title: "Parent edition")

    get :index, params: { parent_edition_id: parent_edition.id }

    assert_select ".app-c-child-of-banner__title", text: /Parent edition/
  end

  view_test "GET #index with a `parent_edition_id` that does not match a standard edition does not show the Child Of Banner" do
    get :index, params: { parent_edition_id: create(:publication).id }

    assert_select ".app-c-child-of-banner", count: 0
  end

  view_test "GET #index with a `parent_edition_id` populates a hidden input in the form" do
    get :index, params: { parent_edition_id: 123 }

    assert_response :success
    assert_select "input[type=hidden][name=parent_edition_id][value=123]"
  end

  view_test "POST #new_document_options with a `parent_edition_id` includes parent_edition_id in the redirect when specified" do
    post :new_document_options_redirect, params: { new_document_options: "news_article", parent_edition_id: 123 }

    assert_redirected_to choose_type_admin_standard_editions_path(group: "news_article", parent_edition_id: 123)
  end

  view_test "GET #index renders formats that require GDS approval in their own alphabetically ordered section" do
    get :index

    assert_response :success
    assert_select "h2.govuk-fieldset__heading", text: "Requires approval from GDS"
    assert_select "#new_document_options_requires_approval input[type=radio][name=new_document_options][value=topical_event]"
  end

  view_test "GET #index does not render the 'Requires approval from GDS' section when no formats require approval" do
    organisation = create(:organisation, name: "ministry-of-defence", handles_fatalities: true)
    login_as(:writer, organisation)
    ConfigurableDocumentType.stubs(:find).with("topical_event").returns(ConfigurableDocumentType.new({ "settings" => { "organisations" => [create(:organisation).content_id] } }))

    get :index

    assert_response :success
    assert_select "h2.govuk-fieldset__heading", text: "Requires approval from GDS", count: 0
  end

  view_test "GET #index renders the Standard Edition option if the feature toggle is on" do
    @test_strategy ||= Flipflop::FeatureSet.current.test!
    @test_strategy.switch!(:configurable_document_types, true)

    get :index

    assert_response :success
    assert_select "input[type=radio][name=new_document_options][value=standard_edition]"

    @test_strategy.switch!(:configurable_document_types, false)
  end

  view_test "GET #index renders the Mini site option if the feature toggle is on" do
    @test_strategy ||= Flipflop::FeatureSet.current.test!
    @test_strategy.switch!(:configurable_document_types, true)

    get :index

    assert_response :success
    assert_select "input[type=radio][name=new_document_options][value=mini_site_landing]"

    @test_strategy.switch!(:configurable_document_types, false)
  end

  view_test "GET #index does not render the topical event radio button for users outside the specified organisation" do
    organisation = create(:organisation, name: "ministry-of-defence", handles_fatalities: true)
    login_as(:writer, organisation)
    ConfigurableDocumentType.stubs(:find).with("topical_event").returns(ConfigurableDocumentType.new({ "settings" => { "organisations" => [create(:organisation).content_id] } }))

    get :index

    assert_response :success
    assert_select "input[type=radio][name=new_document_options][value=topical_event]", count: 0
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
