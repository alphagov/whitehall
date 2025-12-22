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
          "configurable_document_group" => "test_group",
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

class ConfigurableDocumentTypes::Conversions::TestGroup
  def initialize(old_type, new_type)
    @old_type = old_type
    @new_type = new_type
  end

  def convert(edition)
    edition.configurable_document_type = @new_type.key
    edition.save!(validate: false)
  end
end
