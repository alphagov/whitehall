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
            "attributes" => {
              "body" => {
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

  test "respects the locale passed to the block content reader" do
    test_type = "test_type"
    configurable_document_type =
      build_configurable_document_type(
        test_type, {
          "schema" => {
            "attributes" => {
              "body" => {
                "type" => "string",
              },
            },
          },
        }
      )
    ConfigurableDocumentType.setup_test_types(configurable_document_type)
    page = build(:standard_edition, { configurable_document_type: test_type, block_content: { body: "primary locale body" } })
    with_locale(:es) do
      page.block_content = { body: "translated body" }
      assert_equal "translated body", page.block_content.body
      assert_equal "primary locale body", page.block_content(:en).body
    end
  end

  test "updates the document slug if the current translation is for the primary locale" do
    test_type =
      build_configurable_document_type(
        "test_type", {
          "settings" => {
            "translations_enabled" => true,
          },
        }
      )
    ConfigurableDocumentType.setup_test_types(test_type)
    I18n.with_locale(:cy) do
      edition = create(:draft_standard_edition, configurable_document_type: "test_type", primary_locale: "cy", title: "Original Title")
      assert_equal "original-title", edition.document.slug
      edition.update!(title: "New title")
      assert_equal "new-title", edition.document.slug
    end
  end

  test "does not update the document slug if the current translation is not for the primary locale" do
    test_type = build_configurable_document_type(
      "test_type", {
        "settings" => {
          "translations_enabled" => false,
        },
      }
    )
    ConfigurableDocumentType.setup_test_types(test_type)

    edition = nil
    I18n.with_locale(:cy) do
      edition = create(:draft_standard_edition, configurable_document_type: "test_type", primary_locale: "cy", title: "Original Title")
    end
    assert_equal "original-title", edition.document.slug
    edition.update!(title: "New Title")
    assert_equal "original-title", edition.document.slug
  end

  test "it allows features if the configurable document type settings permit them" do
    test_type_with_features =
      build_configurable_document_type(
        "test_type_with_features", {
          "settings" => {
            "features_enabled" => true,
          },
        }
      )
    test_type_without_features =
      build_configurable_document_type(
        "test_type_without_features", {
          "settings" => {
            "features_enabled" => false,
          },
        }
      )

    ConfigurableDocumentType.setup_test_types(test_type_with_features.merge(test_type_without_features))
    page_with_features = StandardEdition.new(configurable_document_type: "test_type_with_features")
    page_without_features = StandardEdition.new(configurable_document_type: "test_type_without_features")
    assert page_with_features.allows_features?
    assert_not page_without_features.allows_features?
  end

  test "it allows images if the configurable document type settings permit them" do
    test_type_with_images =
      build_configurable_document_type(
        "test_type_with_images", {
          "settings" => {
            "images" => {
              "enabled" => true,
            },
          },
        }
      )
    test_type_without_images =
      build_configurable_document_type(
        "test_type_without_images", {
          "settings" => {
            "images" => {
              "enabled" => false,
            },
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
            "attributes" => {
              "test_attribute" => {
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
          "forms" => {
            "documents" => {
              "fields" => {
                "test_object_attribute" => {
                  "title" => "Test object attribute",
                  "block" => "default_object",
                  "fields" => {
                    "test_nested_attribute" => {
                      "title" => "Test nested attribute",
                      "block" => "default_string",
                    },
                  },
                },
              },
            },
          },
          "schema" => {
            "attributes" => {
              "test_nested_attribute" => {
                "type" => "string",
              },
            },
            "validations" => {
              "presence" => {
                "attributes" => %w[test_nested_attribute],
              },
            },
          },
        }
      )
    ConfigurableDocumentType.setup_test_types(configurable_document_type)
    page = build(:standard_edition, { configurable_document_type: test_type, block_content: { test_nested_attribute: "" } })
    assert page.invalid?
    assert_not page.errors.where("test_nested_attribute", :blank).empty?
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
        "attributes" => {
          "test_attribute" => {
            "type" => "string",
          },
          "body" => {
            "type" => "string",
          },
          "image" => {
            "type" => "integer",
          },
        },
      },
      "settings" => {
        "translations_enabled" => true,
        "images" => {
          "enabled" => true,
          "usages" => {
            "govspeak_embed": {
              "label" => "usage",
              "kinds" => %w[default],
              "multiple" => false,
            },
          },
        },
      },
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
      field_attribute: nil, # from the factory
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

  test "features are copied over to new edition of document if the featurable is editionable" do
    english = build(:feature_list, locale: :en)
    french = build(:feature_list, locale: :fr)

    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type"))
    edition = create(:published_standard_edition, configurable_document_type: "test_type", feature_lists: [english, french])

    new_edition = edition.create_draft(User.new)

    assert_equal %w[en fr], new_edition.feature_lists.map(&:locale)
  end

  test "changing the state of the StandardEdition causes a republish of any documents the StandardEdition is featured on" do
    featuring_edition = create(:published_standard_edition)
    feature_list = create(:feature_list, featurable: featuring_edition)

    featured_edition = create(:submitted_standard_edition, major_change_published_at: 1.day.ago)
    feature = feature_list.features.build(document: featured_edition.document, started_at: 1.day.ago)
    feature.image = build(:featured_image_data, featured_imageable: feature)
    feature.save!

    Whitehall::PublishingApi.expects(:republish_document_async).with(featuring_edition.document)
    featured_edition.publish!
  end

  test "changing anything else about StandardEdition does NOT cause a republish of any documents the StandardEdition is featured on" do
    featuring_edition = create(:published_standard_edition)
    feature_list = create(:feature_list, featurable: featuring_edition)

    featured_edition = create(:submitted_standard_edition, major_change_published_at: 1.day.ago)
    feature = feature_list.features.build(document: featured_edition.document, started_at: 1.day.ago)
    feature.image = build(:featured_image_data, featured_imageable: feature)
    feature.save!

    Whitehall::PublishingApi.expects(:republish_document_async).with(featuring_edition.document).never
    featured_edition.update!(title: "Foo")
  end

  test "offsite links are copied over to the new edition of a document" do
    offsite_link_1 = build(:offsite_link, title: "Offsite link 1", url: "https://www.nhs.uk/")
    offsite_link_2 = build(:offsite_link, title: "Offsite link 2", url: "https://www.gov.uk/")
    edition = create(:published_standard_edition, configurable_document_type: "test_type", offsite_links: [offsite_link_1, offsite_link_2])

    new_draft = edition.create_draft(create(:writer))
    assert_equal 2, new_draft.offsite_links.size
    assert_equal offsite_link_1.title, new_draft.offsite_links.first.title
    assert_equal offsite_link_1.url, new_draft.offsite_links.first.url
    assert_equal offsite_link_2.title, new_draft.offsite_links.second.title
    assert_equal offsite_link_2.url, new_draft.offsite_links.second.url
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
            "attributes" => {
              "initial_property" => {
                "type" => "string",
              },
              "common_property" => {
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
            "attributes" => {
              "new_property" => {
                "type" => "string",
              },
              "common_property" => {
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
        "field_attribute" => nil, # from the factory
        "new_property" => nil, # from the new type
        "common_property" => "common value", # retained from previous type
        # initial_property removed
      }, page.block_content.to_h)
    end
  end
end
