require "test_helper"

class PublishingApi::StandardEditionPresenterTest < ActiveSupport::TestCase
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
    page.document = Document.new
    page.document.slug = "page-title"
    presenter = PublishingApi::StandardEditionPresenter.new(page)
    content = presenter.content
    assert_equal "#{base_path_prefix}/#{page.document.slug}", content[:base_path]
    assert_equal schema_name, content[:schema_name]
    assert_equal document_type, content[:document_type]
    assert_equal rendering_app, content[:rendering_app]
  end

  test "it includes the block content values in the details hash" do
    type_key = "test_type_key"
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type(type_key, {
      "schema" => {
        "properties" => {
          "property_one" => {
            "type" => "string",
            "title" => "Property One",
          },
          "property_two" => {
            "type" => "string",
            "title" => "Property Two",
          },
        },
      },
    }))
    page = create(:standard_edition,
                  {
                    configurable_document_type: type_key,
                    block_content: {
                      "property_one" => "Foo",
                      "property_two" => "Bar",
                    },
                  })
    page.document = Document.new
    page.document.slug = "page-title"
    presenter = PublishingApi::StandardEditionPresenter.new(page)
    content = presenter.content
    assert_equal page.block_content["property_one"], content[:details][:property_one]
    assert_equal page.block_content["property_two"], content[:details][:property_two]
  end

  test "it includes a title and a description" do
    type_key = "test_type_key"
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type(type_key))
    page = create(:standard_edition, {
      title: "Page Title",
      summary: "Page Summary",
      configurable_document_type: type_key,
    })
    page.document = Document.new(slug: "page-title")
    presenter = PublishingApi::StandardEditionPresenter.new(page)

    content = presenter.content

    assert_equal page.title, content[:title]
    assert_equal page.summary, content[:description]
  end

  test "it includes headers once, in the details, from all selected blocks, based on the schema configuration" do
    type_key = "test_type_key"
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type(type_key, {
      "schema" => {
        "headings_from" => %w[chunk_of_content_one chunk_of_content_two],
        "properties" => {
          "chunk_of_content_one" => {
            "title" => "A govspeak block",
            "description" => "Some bit of content",
            "type" => "string",
            "format" => "govspeak",
          },
          "string_chunk_of_content" => {
            "title" => "A string",
            "description" => "Some bit of content",
            "type" => "string",
            "format" => "default",
          },
          "chunk_of_content_two" => {
            "title" => "Another govspeak block",
            "description" => "Another bit of content",
            "type" => "string",
            "format" => "govspeak",
          },
        },
      },
    }))
    page = create(:standard_edition, { configurable_document_type: type_key })
    page.document = Document.new
    page.document.slug = "page-title"
    page.block_content = {
      "string_chunk_of_content" => "Head-less content",
      "chunk_of_content_two" => "## Header for chunk two\nSome more content",
      "chunk_of_content_one" => "## Header for chunk one\nSome content",
    }
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
    type_key = "test_type_key"
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type(type_key, {
      "schema" => {
        "headings_from" => %w[chunk_of_content_one chunk_of_content_two],
        "properties" => {
          "chunk_of_content_one" => {
            "title" => "A govspeak block",
            "description" => "Some bit of content",
            "type" => "string",
            "format" => "govspeak",
          },
          "chunk_of_content_two" => {
            "title" => "Another govspeak block",
            "description" => "Another bit of content",
            "type" => "string",
            "format" => "govspeak",
          },
        },
      },
    }))
    page = create(:standard_edition, { configurable_document_type: type_key })
    page.document = Document.new
    page.document.slug = "page-title"
    page.block_content = {
      "chunk_of_content_two" => "Some more content",
      "chunk_of_content_one" => "Some content",
    }
    presenter = PublishingApi::StandardEditionPresenter.new(page)
    content = presenter.content
    expected_details = {
      chunk_of_content_one: "<div class=\"govspeak\"><p>Some content</p>\n</div>",
      chunk_of_content_two: "<div class=\"govspeak\"><p>Some more content</p>\n</div>",
    }

    assert_equal expected_details, content[:details]
  end

  test "it does not include a headers key in the details if the document type is not configured to send headings" do
    type_key = "test_type_key"
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type(type_key, {
      "schema" => {
        "properties" => {
          "chunk_of_content_one" => {
            "title" => "A govspeak block",
            "description" => "Some bit of content",
            "type" => "string",
            "format" => "govspeak",
          },
          "chunk_of_content_two" => {
            "title" => "Another govspeak block",
            "description" => "Another bit of content",
            "type" => "string",
            "format" => "govspeak",
          },
        },
      },
    }))
    page = create(:standard_edition, { configurable_document_type: type_key,
                                       block_content: {
                                         "chunk_of_content_one" => "## Header for chunk one\nSome content",
                                         "chunk_of_content_two" => "## Header for chunk two\nSome more content",
                                       } })
    page.document = Document.new
    page.document.slug = "page-title"
    presenter = PublishingApi::StandardEditionPresenter.new(page)
    content = presenter.content

    assert_nil content[:details][:headers]
  end

  test "it includes a political key in the details if history mode enabled" do
    type_key = "test_type_key"
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type(type_key, {
      "settings" => {
        "history_mode_enabled" => true,
      },
    }))
    page = create(:standard_edition, { configurable_document_type: type_key,
                                       political: true })
    page.document = Document.new
    page.document.slug = "page-title"
    page.expects(:political?).returns(true)
    presenter = PublishingApi::StandardEditionPresenter.new(page)
    content = presenter.content

    assert_equal true, content[:details][:political]
  end

  test "it does not include a political key in the details if history mode not enabled" do
    type_key = "test_type_key"
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type(type_key, {
      "settings" => {
        "history_mode_enabled" => false,
      },
    }))
    page = create(:standard_edition, { configurable_document_type: type_key,
                                       political: true })
    page.document = Document.new
    page.document.slug = "page-title"
    presenter = PublishingApi::StandardEditionPresenter.new(page)
    content = presenter.content

    assert_not content[:details].key?(:political)
  end

  test "it includes change history in the details if sending change history is enabled" do
    type_key = "test_type_key"
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type(type_key, {
      "settings" => {
        "send_change_history" => true,
      },
    }))
    page = create(:published_standard_edition, { configurable_document_type: type_key })
    presenter = PublishingApi::StandardEditionPresenter.new(page)
    content = presenter.content

    assert_equal [{ "public_timestamp" => "2011-11-09T11:11:11.000+00:00", "note" => "change-note" }], content[:details][:change_history]
  end

  test "it does not include change history in the details if sending change history is not enabled" do
    type_key = "test_type_key"
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type(type_key, {
      "settings" => {
        "send_change_history" => false,
      },
    }))
    page = create(:published_standard_edition, { configurable_document_type: type_key })
    presenter = PublishingApi::StandardEditionPresenter.new(page)
    content = presenter.content

    assert_not content[:details].key?(:change_history)
  end

  test "it includes attachments in the details if file attachments are enabled" do
    type_key = "test_type_key"
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type(type_key, {
      "settings" => {
        "file_attachments_enabled" => true,
      },
    }))
    page = create(:standard_edition, { configurable_document_type: type_key })
    page.document = Document.new
    page.document.slug = "page-title"
    attachment = create(:file_attachment)
    page.stubs(attachments_ready_for_publishing: [attachment])
    presenter = PublishingApi::StandardEditionPresenter.new(page)
    content = presenter.content

    assert_equal 1, content[:details][:attachments].length
    assert_equal attachment.title, content[:details][:attachments].first[:title]
  end

  test "it does not include attachments in the details if file attachments are not enabled" do
    type_key = "test_type_key"
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type(type_key, {
      "settings" => {
        "file_attachments_enabled" => false,
      },
    }))
    page = create(:standard_edition, { configurable_document_type: type_key })
    page.document = Document.new
    page.document.slug = "page-title"
    attachment = create(:file_attachment)
    page.stubs(attachments_ready_for_publishing: [attachment])
    presenter = PublishingApi::StandardEditionPresenter.new(page)
    content = presenter.content

    assert_not content[:details].key?(:attachments)
  end

  test "it includes emphasised organisations in the details if the document type has organisations association" do
    type_key = "test_type_key"
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type(type_key, {
      "associations" => [
        { "key" => "organisations" },
      ],
    }))
    organisations = create_list(:organisation, 2)
    page = create(:standard_edition,
                  { configurable_document_type: type_key,
                    lead_organisations: organisations })
    page.document = Document.new
    page.document.slug = "page-title"
    presenter = PublishingApi::StandardEditionPresenter.new(page)
    content = presenter.content
    expected_emphasised_organisations = organisations.map(&:content_id)
    assert_equal expected_emphasised_organisations, content[:details][:emphasised_organisations]
  end

  test "it does not include emphasised organisations in the details if the document type does not have organisations association" do
    type_key = "test_type_key"
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type(type_key))
    organisations = create_list(:organisation, 2)
    page = create(:standard_edition,
                  { configurable_document_type: type_key,
                    lead_organisations: organisations })
    page.document = Document.new
    page.document.slug = "page-title"
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
end
