require "test_helper"

class StandardEditionTest < ActiveSupport::TestCase
  test "does not require some of the standard edition fields" do
    page = StandardEdition.new
    assert_not page.body_required?
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

  test "it allows default lead image behaviour if the schema permits it" do
    test_type_with_default_lead_image =
      build_configurable_document_type(
        "test_type_with_default_lead_image", {
          "settings" => {
            "default_lead_image_enabled" => true,
          },
        }
      )
    test_type_without_default_lead_image =
      build_configurable_document_type(
        "test_type_without_default_lead_image", {
          "settings" => {
            "default_lead_image_enabled" => false,
          },
        }
      )

    ConfigurableDocumentType.setup_test_types(test_type_with_default_lead_image.merge(test_type_without_default_lead_image))
    page_with_default_lead_image = StandardEdition.new(configurable_document_type: "test_type_with_default_lead_image")
    page_without_default_lead_image = StandardEdition.new(configurable_document_type: "test_type_without_default_lead_image")
    assert page_with_default_lead_image.can_have_default_lead_image?
    assert_not page_without_default_lead_image.can_have_default_lead_image?
  end

  test "it is invalid if the block content does not conform to the configurable document type schema" do
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
            "required" => %w[test_attribute],
          },
        }
      )
    ConfigurableDocumentType.setup_test_types(configurable_document_type)
    page = build(:standard_edition, { configurable_document_type: test_type, block_content: {} })
    assert page.invalid?
  end
end
