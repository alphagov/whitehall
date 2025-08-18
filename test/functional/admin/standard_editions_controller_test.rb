require "test_helper"

class Admin::StandardEditionsControllerTest < ActionController::TestCase
  should_be_an_admin_controller

  setup do
    @organisation = create(:organisation)
    login_as :writer, @organisation

    @test_strategy ||= Flipflop::FeatureSet.current.test!
    @test_strategy.switch!(:configurable_document_types, true)
  end

  teardown do
    @test_strategy.switch!(:configurable_document_types, false)
  end

  test "GET new returns a not found response when the configurable documents feature flag is disabled" do
    @test_strategy.switch!(:configurable_document_types, false)
    get :new
    assert_response :not_found
  end

  view_test "GET choose_type scopes the list of types to types that the user has permission to use" do
    configurable_document_types = {
      "test_type_one" => {
        "key" => "test_type_one",
        "schema" => {
          "$schema": "https://json-schema.org/draft/2020-12/schema",
          "$id": "https://www.gov.uk/schemas/test_type/v1",
          "title" => "Test Type One",
          "type" => "object",
          "properties" => {
            "test_attribute" => {
              "title" => "Test Attribute",
              "type" => "string",
            },
          },
        },
        "settings" => {
          "organisations" => [@current_user.organisation.content_id],
        },
      },
      "test_type_two" => {
        "key" => "test_type_two",
        "schema" => {
          "$schema": "https://json-schema.org/draft/2020-12/schema",
          "$id": "https://www.gov.uk/schemas/test_type/v1",
          "title" => "Test Type Two",
          "type" => "object",
          "properties" => {
            "test_attribute" => {
              "title" => "Test Attribute",
              "type" => "string",
            },
          },
        },
        "settings" => {
          "organisations" => [SecureRandom.uuid],
        },
      },
    }
    ConfigurableDocumentType.setup_test_types(configurable_document_types)
    get :choose_type
    assert_response :ok
    assert_dom "label", "Test Type One"
    refute_dom "label", "Test Type Two"
  end

  test "POST create re-renders the new edition template with the submitted flexible page content if the form is invalid" do
    configurable_document_types = {
      "test_type" => {
        "key" => "test_type",
        "schema" => {
          "$schema": "https://json-schema.org/draft/2020-12/schema",
          "$id": "https://www.gov.uk/schemas/test_type/v1",
          "type" => "object",
          "properties" => {
            "test_attribute" => {
              "title" => "Test Attribute",
              "type" => "string",
            },
          },
        },
        "settings" => {},
      },
    }
    ConfigurableDocumentType.setup_test_types(configurable_document_types)

    flexible_page_content = {
      "test_attribute" => "foo",
    }
    post :create, params: { edition: { flexible_page_type: "test_type", flexible_page_content: } }
    assert_template "admin/editions/new"
  end
end
