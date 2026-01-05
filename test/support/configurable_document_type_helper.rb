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

  def build_configurable_document_type_with_forms(type, attributes = {})
    {
      type => {
        "key" => type,
        "title" => "Test type",
        "forms" => {
          "test_attribute" => {
            "fields" => {
              "field_attribute" => {
                "title" => "Test Attribute",
                "block" => "govspeak",
              },
            },
          },
        },
        "schema" => {
          "attributes" => {
            "field_attribute" => {
              "type" => "string",
            },
          },
        },
        "presenters" => {
          "publishing_api" => {
            "field_attribute" => "string",
          },
        },
        "associations" => [],
        "settings" => {
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
