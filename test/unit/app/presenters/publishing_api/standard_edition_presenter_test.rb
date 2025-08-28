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
end
