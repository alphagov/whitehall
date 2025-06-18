require "test_helper"

class PublishingApi::FlexiblePagePresenterTest < ActiveSupport::TestCase
  test "it sets the schema name, document type, base path and rendering app based on the flexible page type settings" do
    schema_name = "test_type_schema"
    document_type = "test_type"
    rendering_app = "government-frontend"
    base_path_prefix = "/government/history"
    type_key = "test_type_key"
    FlexiblePageType.setup_test_types({
      type_key => {
        "key" => type_key,
        "schema" => {
          "type" => "object",
          "properties" => [],
        },
        "settings" => {
          "base_path_prefix" => "/government/history",
          "publishing_api_schema_name" => schema_name,
          "publishing_api_document_type" => document_type,
          "rendering_app" => rendering_app,
        },
      },
    })
    page = FlexiblePage.new
    page.flexible_page_type = type_key
    page.document = Document.new
    page.document.slug = "page-title"
    presenter = PublishingApi::FlexiblePagePresenter.new(page)
    content = presenter.content
    assert_equal "#{base_path_prefix}/#{page.document.slug}", content[:base_path]
    assert_equal schema_name, content[:schema_name]
    assert_equal document_type, content[:document_type]
    assert_equal rendering_app, content[:rendering_app]
  end

  test "it includes the flexible page content values in the details hash" do
    type_key = "test_type_key"
    FlexiblePageType.setup_test_types({
      type_key => {
        "key" => type_key,
        "schema" => {
          "type" => "object",
          "title" => "An object",
          "properties" => {
            "property_one" => {
              "type" => "string",
              "title" => "Property One",
            },
            "property_two" => {
              "type" => "string",
              "title" => "Property Two",
            },
          },
        },
        "settings" => {
          "base_path_prefix" => "/government/test",
          "publishing_api_schema_name" => "schema_name",
          "publishing_api_document_type" => "document_type",
          "rendering_app" => "rendering-app",
        },
      },
    })
    page = FlexiblePage.new
    page.flexible_page_type = type_key
    page.document = Document.new
    page.document.slug = "page-title"
    page.flexible_page_content = {
      "property_one" => "Foo",
      "property_two" => "Bar",
    }
    presenter = PublishingApi::FlexiblePagePresenter.new(page)
    content = presenter.content
    assert_equal page.flexible_page_content["property_one"], content[:details][:property_one]
    assert_equal page.flexible_page_content["property_two"], content[:details][:property_two]
  end
end
