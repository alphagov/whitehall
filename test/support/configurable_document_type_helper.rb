module ConfigurableDocumentTypeHelper
  def build_configurable_document_type(type, attributes = {})
    {
      type => {
        "key" => type,
        "title" => "Test type",
        "schema" => {
          "properties" => {
            "test_attribute" => {
              "title" => "Test Attribute",
              "type" => "string",
            },
          },
        },
        "associations" => [],
        "settings" => {
          "edit_screens" => {
            "document" => %w[test_attribute],
          },
          "base_path_prefix" => "/government/test",
          "publishing_api_schema_name" => "test_article",
          "publishing_api_document_type" => "test_story",
          "rendering_app" => "frontend",
          "images_enabled" => false,
          "organisations" => nil,
          "backdating_enabled" => false,
          "history_mode_enabled" => false,
          "translations_enabled" => false,
        },
      }.deep_merge(attributes),
    }
  end
end
