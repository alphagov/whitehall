require "test_helper"

class StandardEditionTest < ActiveSupport::TestCase
  test "does not require some of the standard edition fields" do
    page = StandardEdition.new
    assert_not page.body_required?
  end

  test "delegates body to block content" do
    test_type = "test_type"
    configurable_document_type =
      build_configurable_document_type(
        test_type, {
          "schema" => {
            "properties" => {
              "body" => {
                "title" => "Body attribute",
                "type" => "string",
              },
            },
          },
        }
      )
    ConfigurableDocumentType.setup_test_types(configurable_document_type)
    page = build(:standard_edition, { configurable_document_type: test_type, block_content: { body: "FOO" } })
    assert_equal "FOO", page.body
  end

  test "it allows images if the configurable document type settings permit them" do
    test_type_with_images =
      build_configurable_document_type(
        "test_type_with_images", {
          "settings" => {
            "images_enabled" => true,
          },
        }
      )
    test_type_without_images =
      build_configurable_document_type(
        "test_type_without_images", {
          "settings" => {
            "images_enabled" => false,
          },
        }
      )

    ConfigurableDocumentType.setup_test_types(test_type_with_images.merge(test_type_without_images))
    page_with_images = StandardEdition.new(configurable_document_type: "test_type_with_images")
    page_without_images = StandardEdition.new(configurable_document_type: "test_type_without_images")
    assert page_with_images.allows_image_attachments?
    assert_not page_without_images.allows_image_attachments?
  end

  test "it allows file attachments if the configurable document type settings permit them" do
    test_type_with_file_attachments =
      build_configurable_document_type(
        "test_type_with_file_attachments", {
          "settings" => {
            "file_attachments_enabled" => true,
          },
        }
      )
    test_type_without_file_attachments =
      build_configurable_document_type(
        "test_type_without_file_attachments", {
          "settings" => {
            "file_attachments_enabled" => false,
          },
        }
      )

    ConfigurableDocumentType.setup_test_types(test_type_with_file_attachments.merge(test_type_without_file_attachments))
    page_with_file_attachments = StandardEdition.new(configurable_document_type: "test_type_with_file_attachments")
    page_without_file_attachments = StandardEdition.new(configurable_document_type: "test_type_without_file_attachments")
    assert page_with_file_attachments.allows_file_attachments?
    assert_not page_without_file_attachments.allows_file_attachments?
  end

  test "it allows backdating if the configurable document type settings permit them" do
    test_type_with_backdating =
      build_configurable_document_type(
        "test_type_with_backdating", {
          "settings" => {
            "backdating_enabled" => true,
          },
        }
      )
    test_type_without_backdating =
      build_configurable_document_type(
        "test_type_without_backdating", {
          "settings" => {
            "backdating_enabled" => false,
          },
        }
      )
    ConfigurableDocumentType.setup_test_types(test_type_with_backdating.merge(test_type_without_backdating))
    page_with_backdating = StandardEdition.new(configurable_document_type: "test_type_with_backdating")
    page_without_backdating = StandardEdition.new(configurable_document_type: "test_type_without_backdating")
    assert page_with_backdating.can_set_previously_published?
    assert_not page_without_backdating.can_set_previously_published?
  end

  test "it allows marking content as political if the history mode configurable document type setting permits it" do
    test_type_with_history_mode =
      build_configurable_document_type(
        "test_type_with_history_mode", {
          "settings" => {
            "history_mode_enabled" => true,
          },
        }
      )
    test_type_without_history_mode =
      build_configurable_document_type(
        "test_type_without_history_mode", {
          "settings" => {
            "history_mode_enabled" => false,
          },
        }
      )

    ConfigurableDocumentType.setup_test_types(test_type_with_history_mode.merge(test_type_without_history_mode))
    page_with_history_mode = StandardEdition.new(configurable_document_type: "test_type_with_history_mode")
    page_without_history_mode = StandardEdition.new(configurable_document_type: "test_type_without_history_mode")
    assert page_with_history_mode.can_be_marked_political?
    assert_not page_without_history_mode.can_be_marked_political?
  end

  test "it is invalid if the block content does not conform to the configurable document type schema validations" do
    test_type = "test_type"
    configurable_document_type =
      build_configurable_document_type(
        test_type, {
          "schema" => {
            "properties" => {
              "test_attribute" => {
                "title" => "Test attribute",
                "type" => "string",
              },
            },
            "validations" => {
              "presence" => {
                "attributes" => %w[test_attribute],
              },
            },
          },
        }
      )
    ConfigurableDocumentType.setup_test_types(configurable_document_type)
    page = build(:standard_edition, { configurable_document_type: test_type, block_content: { test_attribute: "" } })
    assert page.invalid?
    assert_not page.errors.where("test_attribute", :blank).empty?
  end

  test "it is invalid if the nested block content does not conform to the configurable document type schema validations" do
    test_type = "test_type"
    configurable_document_type =
      build_configurable_document_type(
        test_type, {
          "schema" => {
            "properties" => {
              "test_object_attribute" => {
                "title" => "Test object attribute",
                "type" => "object",
                "properties" => {
                  "test_nested_attribute" => {
                    "title" => "Test nested attribute",
                    "type" => "string",
                  },
                },
                "validations" => {
                  "presence" => {
                    "attributes" => %w[test_nested_attribute],
                  },
                },
              },
            },
          },
        }
      )
    ConfigurableDocumentType.setup_test_types(configurable_document_type)
    page = build(:standard_edition, { configurable_document_type: test_type, block_content: { test_object_attribute: { test_nested_attribute: "" } } })
    assert page.invalid?
    assert_not page.errors.where("test_object_attribute.test_nested_attribute", :blank).empty?
  end

  test "it allows translations if the configurable document type settings permit them" do
    test_type_with_translation =
      build_configurable_document_type(
        "test_type_with_translation", {
          "settings" => {
            "translations_enabled" => true,
          },
        }
      )
    test_type_without_translation =
      build_configurable_document_type(
        "test_type_without_translation", {
          "settings" => {
            "translations_enabled" => false,
          },
        }
      )
    ConfigurableDocumentType.setup_test_types(test_type_with_translation.merge(test_type_without_translation))
    page_with_translation = StandardEdition.new(configurable_document_type: "test_type_with_translation")
    page_without_translation = StandardEdition.new(configurable_document_type: "test_type_without_translation")
    assert page_with_translation.translatable?
    assert_not page_without_translation.translatable?
  end

  test "non-English documents exclude English as a translation option" do
    test_type = build_configurable_document_type("test_type", {
      "settings" => { "translations_enabled" => true },
    })
    ConfigurableDocumentType.setup_test_types(test_type)

    welsh_edition = create(:standard_edition,
                           configurable_document_type: "test_type",
                           primary_locale: "cy")

    missing_translations = welsh_edition.missing_translations

    assert_not_includes missing_translations, :en
  end

  test "conditionally requires worldwide organisation and world location associations" do
    test_type = build_configurable_document_type(
      "test_type", {
        "associations" => [
          {
            "key" => "worldwide_organisations",
            "required" => true,
          },
          {
            "key" => "world_locations",
            "required" => false,
          },
          {
            "key" => "organisations",
            "required" => true,
          },
        ],
      }
    )
    ConfigurableDocumentType.setup_test_types(test_type)
    page = StandardEdition.new(configurable_document_type: "test_type")
    assert page.worldwide_organisation_association_required?
    assert_not page.world_location_association_required?
    assert_not page.respond_to?(:organisation_association_required?) # ignores required value for other associations
  end
end
