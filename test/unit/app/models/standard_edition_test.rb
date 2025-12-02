require "test_helper"

class StandardEditionTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

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

  test "it persists a translation's block content when creating a new draft" do
    test_type = build_configurable_document_type("test_type", {
      "schema" => {
        "properties" => {
          "test_attribute" => {
            "title" => "Test Attribute",
            "type" => "string",
          },
          "body" => {
            "title" => "Body",
            "type" => "string",
          },
          "image" => {
            "title" => "Custom lead image",
            "type" => "integer",
          },
        },
      },
      "settings" => { "translations_enabled" => true },
    })
    ConfigurableDocumentType.setup_test_types(test_type)
    image = create(:image)
    english_edition = create(:published_standard_edition,
                             configurable_document_type: "test_type",
                             primary_locale: "en",
                             images: [image],
                             block_content: {
                               test_attribute: "Some test attribute",
                               body: "English body content",
                               image: image.image_data.id,
                             })
    welsh_block_content = {
      test_attribute: "Rhywbeth ar gyfer y maes prawf",
      body: "## Cynnwys y corff yn Gymraeg",
      image: image.image_data.id,
    }
    I18n.with_locale("cy") do
      english_edition.translations.create!(
        locale: "cy",
        title: "Welsh title",
        summary: "Welsh summary",
        block_content: welsh_block_content,
      )
    end

    new_draft = english_edition.create_draft(create(:writer))

    welsh_translation = new_draft.translation_for(:cy)
    assert_equal "Welsh title", welsh_translation.title
    assert_equal "Welsh summary", welsh_translation.summary
    assert_equal welsh_block_content.stringify_keys, welsh_translation.block_content
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

  describe "#update_configurable_document_type" do
    [
      { state: :draft_standard_edition },
      { state: :submitted_standard_edition },
      { state: :rejected_standard_edition },
    ].each do |params|
      it "updates the configurable document type when in #{params[:state].to_s.gsub('_standard_edition', '')} state" do
        initial_type = build_configurable_document_type("initial_type",
                                                        {
                                                          "settings" => {
                                                            "configurable_document_group" => "test_group",
                                                          },
                                                        })
        new_type = build_configurable_document_type("new_type",
                                                    {
                                                      "settings" => {
                                                        "configurable_document_group" => "test_group",
                                                      },
                                                    })
        ConfigurableDocumentType.setup_test_types(initial_type.merge(new_type))
        page = create(params[:state], configurable_document_type: "initial_type")
        assert_equal "initial_type", page.configurable_document_type
        page.update_configurable_document_type("new_type")
        assert_equal "new_type", page.configurable_document_type
      end
    end

    test "avoids updating document type if not in a convertable state" do
      initial_type = build_configurable_document_type("initial_type")
      new_type = build_configurable_document_type("new_type")
      ConfigurableDocumentType.setup_test_types(initial_type.merge(new_type))
      page = create(:published_standard_edition, configurable_document_type: "initial_type")
      result = page.update_configurable_document_type("new_type")
      assert_not result
      assert_equal "initial_type", page.configurable_document_type
    end

    test "avoids updating document type if document type is invalid" do
      test_type = build_configurable_document_type("foo")
      ConfigurableDocumentType.setup_test_types(test_type)
      page = create(:draft_standard_edition, configurable_document_type: "foo")
      result = page.update_configurable_document_type("non_existent_type")
      assert_not result
      assert_equal "foo", page.configurable_document_type
    end

    test "avoids updating document type if it is not in the same configurable_document_group" do
      initial_type = build_configurable_document_type(
        "initial_type", {
          "settings" => {
            "configurable_document_group" => "group_1",
          },
        }
      )
      new_type = build_configurable_document_type(
        "new_type", {
          "settings" => {
            "configurable_document_group" => "group_2",
          },
        }
      )
      ConfigurableDocumentType.setup_test_types(initial_type.merge(new_type))
      page = create(:draft_standard_edition, configurable_document_type: "initial_type")
      result = page.update_configurable_document_type("new_type")
      assert_not result
      assert_equal "initial_type", page.configurable_document_type
    end

    test "drops any invalid properties from block content after changing document type" do
      initial_type = build_configurable_document_type(
        "initial_type", {
          "schema" => {
            "properties" => {
              "initial_property" => {
                "title" => "Initial Property",
                "type" => "string",
              },
              "common_property" => {
                "title" => "Common Property",
                "type" => "string",
              },
            },
          },
          "settings" => {
            "configurable_document_group" => "common_group",
          },
        }
      )
      new_type = build_configurable_document_type(
        "new_type", {
          "schema" => {
            "properties" => {
              "new_property" => {
                "title" => "New Property",
                "type" => "string",
              },
              "common_property" => {
                "title" => "Common Property",
                "type" => "string",
              },
            },
          },
          "settings" => {
            "configurable_document_group" => "common_group",
          },
        }
      )
      ConfigurableDocumentType.setup_test_types(initial_type.merge(new_type))
      page = create(:draft_standard_edition,
                    configurable_document_type: "initial_type",
                    block_content: { initial_property: "value", common_property: "common value" })
      page.update_configurable_document_type("new_type")
      page = StandardEdition.find(page.id) # reload to clear any cached block_content
      assert_equal({
        "test_attribute" => nil, # from the factory
        "new_property" => nil, # from the new type
        "common_property" => "common value", # retained from previous type
        # initial_property removed
      }, page.block_content.to_h)
    end
  end
end
