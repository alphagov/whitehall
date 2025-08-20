require "test_helper"

class PublishingApi::StandardEditionPresenterTest < ActiveSupport::TestCase
  test "it sets the schema name, document type, base path and rendering app based on the document type settings" do
    schema_name = "test_type_schema"
    document_type = "test_type"
    rendering_app = "government-frontend"
    base_path_prefix = "/government/history"
    type_key = "test_type_key"
    ConfigurableDocumentType.setup_test_types({
      type_key => {
        "key" => type_key,
        "schema" => {
          "type" => "object",
          "properties" => [],
        },
        "settings" => {
          "base_path_prefix" => "/government/history",
          "publishing_api_schema_name" => schema_name,
          "publishing_api_document_type" => document_type,
          "rendering_app" => rendering_app,
        },
      },
    })
    page = StandardEdition.new
    page.configurable_document_type = type_key
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
    ConfigurableDocumentType.setup_test_types({
      type_key => {
        "key" => type_key,
        "schema" => {
          "type" => "object",
          "title" => "An object",
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
        "settings" => {
          "base_path_prefix" => "/government/test",
          "publishing_api_schema_name" => "schema_name",
          "publishing_api_document_type" => "document_type",
          "rendering_app" => "rendering-app",
        },
      },
    })
    page = StandardEdition.new
    page.configurable_document_type = type_key
    page.document = Document.new
    page.document.slug = "page-title"
    page.block_content = {
      "property_one" => "Foo",
      "property_two" => "Bar",
    }
    presenter = PublishingApi::StandardEditionPresenter.new(page)
    content = presenter.content
    assert_equal page.block_content["property_one"], content[:details][:property_one]
    assert_equal page.block_content["property_two"], content[:details][:property_two]
  end

  test "it includes headers for each govspeak type block" do
    type_key = "test_type_key"
    ConfigurableDocumentType.setup_test_types({
      type_key => {
        "key" => type_key,
        "schema" => {
          "type" => "object",
          "title" => "An object",
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
        "settings" => {
          "base_path_prefix" => "/government/test",
          "publishing_api_schema_name" => "schema_name",
          "publishing_api_document_type" => "document_type",
          "rendering_app" => "rendering-app",
        },
      },
    })
    page = StandardEdition.new
    page.configurable_document_type = type_key
    page.document = Document.new
    page.document.slug = "page-title"
    page.block_content = {
      "chunk_of_content_one" => "## Header for chunk one\n\nSome content",
      "chunk_of_content_two" => "## Header for chunk two\n\nSome more content",
    }
    presenter = PublishingApi::StandardEditionPresenter.new(page)
    content = presenter.content
    expected_hash_for_chunk_of_content_one = {
      html: "<div class=\"govspeak\"><h2 id=\"header-for-chunk-one\">Header for chunk one</h2> <p>Some content</p> </div>",
      headers: [
        {
          text: "Header for chunk one",
          level: 2,
          id: "header-for-chunk-one",
        },
      ],
    }
    expected_hash_for_chunk_of_content_two = {
      html: "<div class=\"govspeak\"><h2 id=\"header-for-chunk-two\">Header for chunk two</h2> <p>Some more content</p> </div>",
      headers: [
        {
          text: "Header for chunk two",
          level: 2,
          id: "header-for-chunk-two",
        },
      ],
    }
    assert_equal expected_hash_for_chunk_of_content_one[:html], content[:details][:chunk_of_content_one][:html].squish
    assert_equal expected_hash_for_chunk_of_content_one[:headers], content[:details][:chunk_of_content_one][:headers]
    assert_equal expected_hash_for_chunk_of_content_two[:html], content[:details][:chunk_of_content_two][:html].squish
    assert_equal expected_hash_for_chunk_of_content_two[:headers], content[:details][:chunk_of_content_two][:headers]
  end

  test "it includes headers once, one layer up, if there is a govspeak block with a 'body' key" do
    type_key = "test_type_key"
    ConfigurableDocumentType.setup_test_types({
      type_key => {
        "key" => type_key,
        "schema" => {
          "type" => "object",
          "title" => "An object",
          "properties" => {
            "body" => {
              "title" => "Body",
              "description" => "The main content for the page",
              "type" => "string",
              "format" => "govspeak",
            },
          },
        },
        "settings" => {
          "base_path_prefix" => "/government/test",
          "publishing_api_schema_name" => "schema_name",
          "publishing_api_document_type" => "document_type",
          "rendering_app" => "rendering-app",
        },
      },
    })
    page = StandardEdition.new
    page.configurable_document_type = type_key
    page.document = Document.new
    page.document.slug = "page-title"
    page.block_content = {
      "body" => "## Header for content\n\nSome content",
    }
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
end
