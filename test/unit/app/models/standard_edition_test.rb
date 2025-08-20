require "test_helper"

class StandardEditionTest < ActiveSupport::TestCase
  test "does not require some of the standard edition fields" do
    page = StandardEdition.new
    assert_not page.summary_required?
    assert_not page.body_required?
    assert_not page.can_set_previously_published?
    assert_not page.previously_published
  end

  test "it allows images if the configurable document type settings permit them" do
    test_types = {
      "test_type_with_images" => {
        "key" => "test_type_with_images",
        "schema" => {
          "$schema": "https://json-schema.org/draft/2020-12/schema",
          "$id": "https://www.gov.uk/schemas/test_type/v1",
          "title": "Test type",
          "type": "object",
          "properties" => {
            "test_attribute" => {
              "title" => "Test attribute",
              "type" => "string",
            },
          },
          "required" => %w[test_attribute],
        },
        "settings" => {
          "images_enabled" => true,
        },
      },
      "test_type_without_images" => {
        "key" => "test_type_without_images",
        "schema" => {
          "$schema": "https://json-schema.org/draft/2020-12/schema",
          "$id": "https://www.gov.uk/schemas/test_type/v1",
          "title": "Test type",
          "type": "object",
          "properties" => {
            "test_attribute" => {
              "title" => "Test attribute",
              "type" => "string",
            },
          },
          "required" => %w[test_attribute],
        },
        "settings" => {
          "images_enabled" => false,
        },
      },
    }
    ConfigurableDocumentType.setup_test_types(test_types)
    page_with_images = StandardEdition.new(configurable_document_type: "test_type_with_images")
    page_without_images = StandardEdition.new(configurable_document_type: "test_type_without_images")
    assert page_with_images.allows_image_attachments?
    assert_not page_without_images.allows_image_attachments?
  end

  test "it is invalid if the block content does not conform to the configurable document type schema" do
    test_types = {
      "test_type" => {
        "key" => "test_type",
        "schema" => {
          "$schema": "https://json-schema.org/draft/2020-12/schema",
          "$id": "https://www.gov.uk/schemas/test_type/v1",
          "title": "Test type",
          "type": "object",
          "properties" => {
            "test_attribute" => {
              "title" => "Test attribute",
              "type" => "string",
            },
          },
          "required" => %w[test_attribute],
        },
        "settings" => {},
      },
    }
    ConfigurableDocumentType.setup_test_types(test_types)
    page = StandardEdition.new
    page.title = "Test Page"
    page.configurable_document_type = "test_type"
    page.block_content = {}
    page.creator = User.new
    assert page.invalid?
  end
end
