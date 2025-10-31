require "test_helper"

class ConfigurableDocumentTypeTest < ActiveSupport::TestCase
  test "#find raises an error if the type is not specified" do
    error = assert_raises(ConfigurableDocumentType::NotFoundError) { ConfigurableDocumentType.find(nil) }
    assert_equal "No document type specified", error.message
  end

  test "#find raises an error if the type is not found" do
    error = assert_raises(ConfigurableDocumentType::NotFoundError) { ConfigurableDocumentType.find("non_existent_type") }
    assert_equal "No document type found for 'non_existent_type'", error.message
  end

  test ".properties_for_edit_screen returns properties for a given edit screen" do
    body_property = {
      "title" => "Body",
      "description" => "The main content of the page",
      "type" => "string",
      "format" => "govspeak",
    }
    another_property = {
      "title" => "Another Property",
      "description" => "Another property for testing",
      "type" => "string",
    }
    image_property = {
      "title" => "Image",
      "description" => "The image for the page",
      "type" => "integer",
      "format" => "image_select",
    }
    configurable_document_type = build_configurable_document_type(
      "test_type",
      {
        "schema" => {
          "properties" => {
            "body" => body_property,
            "another_property" => another_property,
            "image" => image_property,
          },
        },
        "settings" => {
          "edit_screens" => {
            "document" => %w[body another_property],
            "images" => %w[image],
          },
        },
      },
    )
    ConfigurableDocumentType.setup_test_types(configurable_document_type)
    document_type = ConfigurableDocumentType.find("test_type")

    assert_equal({ "body" => body_property, "another_property" => another_property }, document_type.properties_for_edit_screen("document"))
    assert_equal({ "image" => image_property }, document_type.properties_for_edit_screen("images"))
  end
end
