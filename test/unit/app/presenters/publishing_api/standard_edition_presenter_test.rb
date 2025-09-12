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

    page = build(:standard_edition, { configurable_document_type: type_key })
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
    page = build(:standard_edition,
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
    page = build(:standard_edition, {
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

  test "it includes headers once, in the details, from all govspeak blocks, based on the order they are listed in the schema" do
    type_key = "test_type_key"
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type(type_key, {
      "settings" => {
        "send_headings" => true,
      },
      "schema" => {
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
    page = build(:standard_edition, { configurable_document_type: type_key })
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
      headers: [{
        text: "Header for chunk one",
        level: 2,
        id: "header-for-chunk-one",
      },
                {
                  text: "Header for chunk two",
                  level: 2,
                  id: "header-for-chunk-two",
                }],

    }

    assert_equal expected_details, content[:details]
  end

  test "it includes headers once, one layer up, if there is a govspeak block with a 'body' key" do
    type_key = "test_type_key"
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type(type_key, {
      "settings" => {
        "send_headings" => true,
      },
      "schema" => {
        "properties" => {
          "body" => {
            "title" => "Body",
            "description" => "The main content for the page",
            "type" => "string",
            "format" => "govspeak",
          },
        },
      },
    }))
    page = build(:standard_edition, { configurable_document_type: type_key,
                                      block_content: {
                                        "body" => "## Header for content\n\nSome content",
                                      } })
    page.document = Document.new
    page.document.slug = "page-title"
    presenter = PublishingApi::StandardEditionPresenter.new(page)
    content = presenter.content

    expected_body = "<div class=\"govspeak\"><h2 id=\"header-for-content\">Header for content</h2> <p>Some content</p> </div>"
    expected_headers = [
      {
        text: "Header for content",
        level: 2,
        id: "header-for-content",
      },
    ]
    assert_equal expected_body, content[:details][:body].squish
    assert_equal expected_headers, content[:details][:headers]
  end

  test "it does not include a headers key in the details if there are no headers in any of the content blocks" do
    type_key = "test_type_key"
    ConfigurableDocumentType.setup_test_types(
      build_configurable_document_type(type_key, {
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
      }),
    )
    page = build(:standard_edition, { configurable_document_type: type_key,
                                      block_content: {
                                        "chunk_of_content_one" => "Some content",
                                        "chunk_of_content_two" => "Some more content",
                                      } })
    page.document = Document.new
    page.document.slug = "page-title"
    presenter = PublishingApi::StandardEditionPresenter.new(page)
    content = presenter.content

    assert_nil content[:details][:headers]
  end

  test "it does not include a headers key in the details if the document type is not configured to send headings" do
    type_key = "test_type_key"
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type(type_key, {
      "settings" => {
        "send_headings" => false,
      },
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
    page = build(:standard_edition, { configurable_document_type: type_key,
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
    page = build(:standard_edition, { configurable_document_type: type_key,
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
    page = build(:standard_edition, { configurable_document_type: type_key,
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
    page = build(:standard_edition, { configurable_document_type: type_key })
    page.document = Document.new
    page.document.slug = "page-title"
    attachment = build(:file_attachment)
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
    page = build(:standard_edition, { configurable_document_type: type_key })
    page.document = Document.new
    page.document.slug = "page-title"
    attachment = build(:file_attachment)
    page.stubs(attachments_ready_for_publishing: [attachment])
    presenter = PublishingApi::StandardEditionPresenter.new(page)
    content = presenter.content

    assert_not content[:details].key?(:attachments)
  end

  test "#links includes the selected content IDs for each configured association" do
    ConfigurableDocumentType.setup_test_types(
      build_configurable_document_type("test_type", {
        "associations" => [
          {
            "key" => "ministerial_role_appointments",
          },
          {
            "key" => "topical_events",
          },
          {
            "key" => "world_locations",
          },
          {
            "key" => "organisations",
          },
        ],
      }),
    )
    ministerial_role_appointments = create_list(:ministerial_role_appointment, 2)
    topical_events = create_list(:topical_event, 2)
    world_locations = create_list(:world_location, 2, active: true)
    organisations = create_list(:organisation, 2)
    edition = build(:standard_edition,
                    role_appointments: ministerial_role_appointments,
                    topical_events:,
                    world_locations:)
    edition.edition_organisations.build([{ organisation: organisations.first, lead: true, lead_ordering: 0 }, { organisation: organisations.last, lead: false }])
    presenter = PublishingApi::StandardEditionPresenter.new(edition)
    links = presenter.links
    expected_role_appointments = ministerial_role_appointments.map { |appointment| appointment.person.content_id }
    assert_equal expected_role_appointments, links[:role_appointments]
    expected_topical_events = topical_events.map(&:content_id)
    assert_equal expected_topical_events, links[:topical_events]
    expected_world_locations = world_locations.map(&:content_id)
    assert_equal expected_world_locations, links[:world_locations]
    expected_organisations = organisations.map(&:content_id)
    assert_equal expected_organisations, links[:organisations]
    expected_primary_publishing_organisation = organisations.first.content_id
    assert_equal expected_primary_publishing_organisation, links[:primary_publishing_organisation]
  end
end
