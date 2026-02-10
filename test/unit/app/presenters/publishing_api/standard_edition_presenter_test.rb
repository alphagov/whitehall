require "test_helper"

class PublishingApi::StandardEditionPresenterTest < ActiveSupport::TestCase
  include GovspeakHelper

  test "it sets the schema name, document type, base path and rendering app based on the document type settings" do
    schema_name = "test_type_schema"
    document_type = "test_type"
    rendering_app = "government-frontend"
    base_path_prefix = "/government/history"
    type_key = "test_type_key"

    ConfigurableDocumentType.setup_test_types(build_configurable_document_type(type_key, {
      "settings" => {
        "base_path_prefix" => "/government/history",
        "publishing_api_schema_name" => schema_name,
        "publishing_api_document_type" => document_type,
        "rendering_app" => rendering_app,
      },
    }))
    page = create(:standard_edition, { configurable_document_type: type_key })
    presenter = PublishingApi::StandardEditionPresenter.new(page)
    content = presenter.content

    assert_equal "#{base_path_prefix}/#{page.document.slug}", content[:base_path]
    assert_equal schema_name, content[:schema_name]
    assert_equal document_type, content[:document_type]
    assert_equal rendering_app, content[:rendering_app]
  end

  test "it includes the block content values in the details hash" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", {
      "schema" => {
        "attributes" => {
          "attribute_one" => {
            "type" => "string",
          },
          "attribute_two" => {
            "type" => "string",
          },
        },
      },
      "presenters" => {
        "publishing_api" => {
          "attribute_one" => "raw",
          "attribute_two" => "raw",
        },
      },
    }))
    page = create(:standard_edition,
                  block_content: {
                    "attribute_one" => "Foo",
                    "attribute_two" => "Bar",
                  })
    presenter = PublishingApi::StandardEditionPresenter.new(page)
    content = presenter.content

    assert_equal page.block_content["attribute_one"], content[:details][:attribute_one]
    assert_equal page.block_content["attribute_two"], content[:details][:attribute_two]
  end

  test "it includes a title and a description" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type"))
    page = create(:standard_edition,
                  title: "Page Title",
                  summary: "Page Summary")
    presenter = PublishingApi::StandardEditionPresenter.new(page)
    content = presenter.content

    assert_equal page.title, content[:title]
    assert_equal page.summary, content[:description]
  end

  test "it includes headers once, in the details, from all selected blocks, based on the schema configuration" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", {
      "schema" => {
        "headings_from" => %w[chunk_of_content_one chunk_of_content_two],
        "attributes" => {
          "chunk_of_content_one" => {
            "type" => "string",
          },
          "string_chunk_of_content" => {
            "type" => "string",
          },
          "chunk_of_content_two" => {
            "type" => "string",
          },
        },
      },
      "presenters" => {
        "publishing_api" => {
          "string_chunk_of_content" => "raw",
          "chunk_of_content_one" => "govspeak",
          "chunk_of_content_two" => "govspeak",
        },
      },
    }))
    page = create(:standard_edition,
                  block_content: {
                    "string_chunk_of_content" => "Head-less content",
                    "chunk_of_content_one" => "## Header for chunk one\nSome content",
                    "chunk_of_content_two" => "## Header for chunk two\nSome more content",
                  })
    presenter = PublishingApi::StandardEditionPresenter.new(page)
    content = presenter.content

    expected_details = {
      chunk_of_content_one: "<div class=\"govspeak\"><h2 id=\"header-for-chunk-one\">Header for chunk one</h2>\n<p>Some content</p>\n</div>",
      string_chunk_of_content: "Head-less content",
      chunk_of_content_two: "<div class=\"govspeak\"><h2 id=\"header-for-chunk-two\">Header for chunk two</h2>\n<p>Some more content</p>\n</div>",
      headers: [
        {
          text: "Header for chunk one",
          level: 2,
          id: "header-for-chunk-one",
        },
        {
          text: "Header for chunk two",
          level: 2,
          id: "header-for-chunk-two",
        },
      ],
    }

    assert_equal expected_details, content[:details]
  end

  test "it omits the headers key from the payload if none are present in the selected content" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", {
      "schema" => {
        "headings_from" => %w[chunk_of_content_one chunk_of_content_two],
        "attributes" => {
          "chunk_of_content_one" => {
            "type" => "string",
          },
          "chunk_of_content_two" => {
            "type" => "string",
          },
        },
      },
      "presenters" => {
        "publishing_api" => {
          "chunk_of_content_one" => "govspeak",
          "chunk_of_content_two" => "govspeak",
        },
      },
    }))
    page = create(:standard_edition,
                  block_content: {
                    "chunk_of_content_two" => "Some more content",
                    "chunk_of_content_one" => "Some content",
                  })
    presenter = PublishingApi::StandardEditionPresenter.new(page)
    content = presenter.content

    expected_details = {
      chunk_of_content_one: "<div class=\"govspeak\"><p>Some content</p>\n</div>",
      chunk_of_content_two: "<div class=\"govspeak\"><p>Some more content</p>\n</div>",
    }
    assert_equal expected_details, content[:details]
  end

  test "it does not include a headers key in the details if the document type is not configured to send headings" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", {
      "schema" => {
        "attributes" => {
          "chunk_of_content_one" => {
            "type" => "string",
          },
          "chunk_of_content_two" => {
            "type" => "string",
          },
        },
      },
      "presenters" => {
        "publishing_api" => {
          "chunk_of_content_one" => "govspeak",
          "chunk_of_content_two" => "govspeak",
        },
      },
    }))
    page = create(:standard_edition,
                  block_content: {
                    "chunk_of_content_one" => "## Header for chunk one\nSome content",
                    "chunk_of_content_two" => "## Header for chunk two\nSome more content",
                  })
    presenter = PublishingApi::StandardEditionPresenter.new(page)
    content = presenter.content

    assert_nil content[:details][:headers]
  end

  test "it includes a political key in the details if history mode enabled" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", {
      "settings" => {
        "history_mode_enabled" => true,
      },
    }))
    page = create(:standard_edition, political: true)
    page.expects(:political?).returns(true)
    presenter = PublishingApi::StandardEditionPresenter.new(page)
    content = presenter.content

    assert_equal true, content[:details][:political]
  end

  test "it does not include a political key in the details if history mode not enabled" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", {
      "settings" => {
        "history_mode_enabled" => false,
      },
    }))
    page = create(:standard_edition, political: true)
    presenter = PublishingApi::StandardEditionPresenter.new(page)
    content = presenter.content

    assert_not content[:details].key?(:political)
  end

  test "it includes change history in the details if sending change history is enabled" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", {
      "settings" => {
        "send_change_history" => true,
      },
    }))
    page = create(:published_standard_edition)
    presenter = PublishingApi::StandardEditionPresenter.new(page)
    content = presenter.content

    assert_equal [{ "public_timestamp" => "2011-11-09T11:11:11.000+00:00", "note" => "change-note" }], content[:details][:change_history]
  end

  test "it does not include change history in the details if sending change history is not enabled" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", {
      "settings" => {
        "send_change_history" => false,
      },
    }))
    page = create(:published_standard_edition)
    presenter = PublishingApi::StandardEditionPresenter.new(page)
    content = presenter.content

    assert_not content[:details].key?(:change_history)
  end

  test "it includes attachments in the details if file attachments are enabled" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", {
      "settings" => {
        "file_attachments_enabled" => true,
      },
    }))
    page = create(:standard_edition)
    attachment = create(:file_attachment)
    page.stubs(attachments_ready_for_publishing: [attachment])
    presenter = PublishingApi::StandardEditionPresenter.new(page)
    content = presenter.content

    assert_equal 1, content[:details][:attachments].length
    assert_equal attachment.title, content[:details][:attachments].first[:title]
  end

  test "it does not include attachments in the details if file attachments are not enabled" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", {
      "settings" => {
        "file_attachments_enabled" => false,
      },
    }))
    page = create(:standard_edition)
    attachment = create(:file_attachment)
    page.stubs(attachments_ready_for_publishing: [attachment])
    presenter = PublishingApi::StandardEditionPresenter.new(page)
    content = presenter.content

    assert_not content[:details].key?(:attachments)
  end

  test "it includes emphasised organisations in the details if the document type has organisations association" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", {
      "associations" => [
        { "key" => "organisations" },
      ],
    }))
    organisations = create_list(:organisation, 2)
    page = create(:standard_edition, lead_organisations: organisations)
    presenter = PublishingApi::StandardEditionPresenter.new(page)
    content = presenter.content
    expected_emphasised_organisations = organisations.map(&:content_id)

    assert_equal expected_emphasised_organisations, content[:details][:emphasised_organisations]
  end

  test "it does not include emphasised organisations in the details if the document type does not have organisations association" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type"))
    organisations = create_list(:organisation, 2)
    page = create(:standard_edition, lead_organisations: organisations)
    presenter = PublishingApi::StandardEditionPresenter.new(page)
    content = presenter.content
    assert_not content[:details].key?(:emphasised_organisations)
  end

  test "#links includes the required content IDs" do
    ConfigurableDocumentType.setup_test_types(
      build_configurable_document_type("test_type", {
        "associations" => [
          {
            "key" => "world_locations",
          },
        ],
        "settings" => {
          "history_mode_enabled" => true,
        },
      }),
    )
    world_locations = create_list(:world_location, 2, active: true)
    government = create(:government)
    edition = create(:standard_edition,
                     world_locations:,
                     government_id: government.id)
    presenter = PublishingApi::StandardEditionPresenter.new(edition)
    links = presenter.links
    expected_world_locations = world_locations.map(&:content_id)
    assert_equal expected_world_locations, links[:world_locations]
    expected_government = [edition.government.content_id]
    assert_equal expected_government, links[:government]
  end

  test "it includes non-embeddable images in the details if the config setting for 'images' is enabled" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", {
      "settings" => {
        "images" => {
          "enabled" => true,
          "usages" => {
            "govspeak_embed" => {
              "kinds" => %w[some_embeddable_kind],
              "multiple" => true,
            },
            "non_embeddable_usage" => {
              "kinds" => %w[non_embeddable_usage_kind],
              "multiple" => false,
            },
          },
        },
      },
    }))

    embeddable_image = create(:image, :jpg, usage: "govspeak_embed")
    non_embeddable_image = create(:image, :svg, usage: "non_embeddable_usage", caption: "image caption")
    page = create(:standard_edition, images: [embeddable_image, non_embeddable_image])

    presenter = PublishingApi::StandardEditionPresenter.new(page)
    content = presenter.content

    assert_equal 1, content[:details][:images].length
    assert_equal non_embeddable_image.image_data.url, content[:details][:images].first[:url]
    assert_equal non_embeddable_image.usage, content[:details][:images].first[:type]
    assert_equal non_embeddable_image.caption, content[:details][:images].first[:caption]
    assert_equal non_embeddable_image.content_type, content[:details][:images].first[:content_type]
  end

  test "it does not include images in the details if the config setting for 'images' is not enabled" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", {
      "settings" => {
        "images" => {
          "enabled" => false,
          "usages" => {
            "some_usage" => {
              "kinds" => %w[some_usage_kind],
              "multiple" => true,
            },
          },
        },
      },
    }))

    page = create(:standard_edition)
    presenter = PublishingApi::StandardEditionPresenter.new(page)
    content = presenter.content

    assert_not content[:details].key?(:images)
  end

  test "it does not conflict embeddable and non-embeddable images in the payload, and can present both" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", {
      "settings" => {
        "images" => {
          "enabled" => true,
          "usages" => {
            "govspeak_embed" => {
              "kinds" => %w[some_embeddable_kind],
              "multiple" => true,
            },
            "non_embeddable_usage" => {
              "kinds" => %w[non_embeddable_usage_kind],
              "multiple" => true,
            },
          },
        },
      },
    }))
    embeddable_image = create(:image, :jpg, usage: "govspeak_embed")
    non_embeddable_image = create(:image, :svg, usage: "non_embeddable_usage")
    page = create(:standard_edition,
                  {
                    images: [embeddable_image, non_embeddable_image],
                  })

    presenter = PublishingApi::StandardEditionPresenter.new(page)
    content = presenter.content

    assert_equal 1, content[:details][:images].size
    assert_equal [non_embeddable_image.usage], content[:details][:images].pluck(:type)
  end

  test "it includes the features of the edition in the details if the document type has features enabled" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", {
      "settings" => {
        "features_enabled" => true,
      },
    }))
    featuring_edition = create(:published_standard_edition)

    edition_1 = create(:published_standard_edition)
    edition_2 = create(:published_standard_edition)

    first_feature = create(:feature, document: edition_1.document, ordering: 1)
    second_feature = create(:feature, document: edition_2.document, ordering: 2)

    create(:feature_list, featurable: featuring_edition, features: [first_feature, second_feature])
    presenter = PublishingApi::StandardEditionPresenter.new(featuring_edition)
    content = presenter.content

    expected_ordered_featured_documents = [
      {
        title: edition_1.title,
        href: edition_1.base_path,
        image: { url: "#{Plek.asset_root}/media/asset_manager_id_original/minister-of-funk.960x640.jpg",
                 medium_resolution_url: "#{Plek.asset_root}/media/asset_manager_id_s465/s465_minister-of-funk.960x640.jpg",
                 high_resolution_url: "#{Plek.asset_root}/media/asset_manager_id_s712/s712_minister-of-funk.960x640.jpg",
                 alt_text: "" },
        summary: govspeak_to_html(edition_1.summary),
        public_updated_at: edition_1.public_timestamp,
        document_type: "Test type",

      },
      {
        title: edition_2.title,
        href: edition_2.base_path,
        image: { url: "#{Plek.asset_root}/media/asset_manager_id_original/minister-of-funk.960x640.jpg",
                 medium_resolution_url: "#{Plek.asset_root}/media/asset_manager_id_s465/s465_minister-of-funk.960x640.jpg",
                 high_resolution_url: "#{Plek.asset_root}/media/asset_manager_id_s712/s712_minister-of-funk.960x640.jpg",
                 alt_text: "" },
        summary: govspeak_to_html(edition_2.summary),
        public_updated_at: edition_2.public_timestamp,
        document_type: "Test type",
      },
    ]

    assert_equal expected_ordered_featured_documents, content[:details][:ordered_featured_documents]
  end

  test "it does not include features in the details if the document type does not have features enabled" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", {
      "settings" => {
        "features_enabled" => false,
      },
    }))
    featuring_edition = create(:published_standard_edition)

    edition_1 = create(:published_standard_edition)
    edition_2 = create(:published_standard_edition)

    first_feature = create(:feature, document: edition_1.document, ordering: 1)
    second_feature = create(:feature, document: edition_2.document, ordering: 2)

    create(:feature_list, featurable: featuring_edition, features: [first_feature, second_feature])
    presenter = PublishingApi::StandardEditionPresenter.new(featuring_edition)
    content = presenter.content

    assert_not content[:details].key?(:ordered_featured_documents)
  end
  test "it includes the features for the correct locale when the edition has multiple locales" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", {
      "settings" => {
        "features_enabled" => true,
      },
    }))
    featuring_edition = create(:published_standard_edition)

    english_edition = create(:published_standard_edition, title: "English Featured")
    welsh_edition = create(:published_standard_edition, title: "Welsh Featured")

    english_feature = create(:feature, document: english_edition.document, ordering: 1)
    welsh_feature = create(:feature, document: welsh_edition.document, ordering: 1)

    create(:feature_list, featurable: featuring_edition, locale: :en, features: [english_feature])
    create(:feature_list, featurable: featuring_edition, locale: :cy, features: [welsh_feature])

    presenter = PublishingApi::StandardEditionPresenter.new(featuring_edition)

    I18n.with_locale(:en) do
      content = presenter.content
      title = content[:details][:ordered_featured_documents].first[:title]
      assert_equal "English Featured", title
      assert_not_equal "Welsh Featured", title
    end

    I18n.with_locale(:cy) do
      content = presenter.content
      title = content[:details][:ordered_featured_documents].first[:title]
      assert_equal "Welsh Featured", title
      assert_not_equal "English Featured", title
    end
  end

  test "it does not include features for a locale with no feature list" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", {
      "settings" => {
        "features_enabled" => true,
      },
    }))
    featuring_edition = create(:published_standard_edition)

    english_edition = create(:published_standard_edition)
    english_feature = create(:feature, document: english_edition.document, ordering: 1)
    create(:feature_list, featurable: featuring_edition, locale: :en, features: [english_feature])

    presenter = PublishingApi::StandardEditionPresenter.new(featuring_edition)

    I18n.with_locale(:cy) do
      content = presenter.content
      assert_equal [], content[:details][:ordered_featured_documents]
    end
  end
end
