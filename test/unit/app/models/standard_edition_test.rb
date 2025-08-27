require "test_helper"

class StandardEditionTest < ActiveSupport::TestCase
  test "does not require some of the standard edition fields" do
    page = StandardEdition.new
    assert_not page.body_required?
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

  test "it allows backdating if the configurable document type settings permit them" do
    test_types = {
      "test_type_with_backdating" => {
        "key" => "test_type_with_backdating",
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
          "backdating_enabled" => true,
        },
      },
      "test_type_without_backdating" => {
        "key" => "test_type_without_backdating",
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
          "backdating_enabled" => false,
        },
      },
    }
    ConfigurableDocumentType.setup_test_types(test_types)
    page_with_backdating = StandardEdition.new(configurable_document_type: "test_type_with_backdating")
    page_without_backdating = StandardEdition.new(configurable_document_type: "test_type_without_backdating")
    assert page_with_backdating.can_set_previously_published?
    assert_not page_without_backdating.can_set_previously_published?
  end

  test "it allows marking content as political if the history mode configurable document type setting permits it" do
    test_types = {
      "test_type_with_history_mode" => {
        "key" => "test_type_with_history_mode",
        "schema" => {
          "$schema": "https://json-schema.org/draft/2020-12/schema",
          "$id": "https://www.gov.uk/schemas/test_type/v1",
          "title": "Test type",
          "type": "object",
          "properties" => {
            "test_attribute" => {
              "title": "Test attribute",
              "type": "string",
            },
          },
          "required" => %w[test_attribute],
        },
        "settings" => {
          "history_mode_enabled" => true,
        },
      },
      "test_type_without_history_mode" => {
        "key" => "test_type_without_history_mode",
        "schema" => {
          "$schema": "https://json-schema.org/draft/2020-12/schema",
          "$id": "https://www.gov.uk/schemas/test_type/v1",
          "title": "Test type",
          "type": "object",
          "properties" => {
            "test_attribute" => {
              "title": "Test attribute",
              "type": "string",
            },
          },
          "required" => %w[test_attribute],
        },
        "settings" => {
          "history_mode_enabled" => false,
        },
      },
    }
    ConfigurableDocumentType.setup_test_types(test_types)
    page_with_history_mode = StandardEdition.new(configurable_document_type: "test_type_with_history_mode")
    page_without_history_mode = StandardEdition.new(configurable_document_type: "test_type_without_history_mode")
    assert page_with_history_mode.can_be_marked_political?
    assert_not page_without_history_mode.can_be_marked_political?
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
    page = build(:standard_edition, { configurable_document_type: "test_type", block_content: {} })
    assert page.invalid?
  end
end
