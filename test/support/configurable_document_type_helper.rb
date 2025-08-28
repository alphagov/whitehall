module ConfigurableDocumentTypeHelper
  def build_configurable_document_type(type, attributes = {})
    {
      type => {
        "key" => type,
        "schema" => {
          "$schema": "https://json-schema.org/draft/2020-12/schema",
          "$id": "https://www.gov.uk/schemas/test_type/v1",
          "title" => "Test type",
          "type" => "object",
          "properties" => {
            "test_attribute" => {
              "title" => "Test Attribute",
              "type" => "string",
            },
          },
        },
        "settings" => {
          "base_path_prefix" => "/government/test",
          "publishing_api_schema_name" => "test_article",
          "publishing_api_document_type" => "test_story",
          "rendering_app" => "frontend",
          "images_enabled" => false,
          "organisations" => nil,
          "backdating_enabled" => false,
          "history_mode_enabled" => false,
        },
      }.deep_merge(attributes),
    }
  end
end
