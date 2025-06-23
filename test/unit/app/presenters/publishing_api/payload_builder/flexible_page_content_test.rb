require "test_helper"
class PublishingApi::PayloadBuilder::FlexiblePageContentTest < ActiveSupport::TestCase
  test "it presents basic string fields" do
    test_schema = {
      "$schema" => "https://json-schema.org/draft/2020-12/schema",
      "$id" => "https://www.gov.uk/schemas/test_type/v1",
      "title" => "Test type",
      "type" => "object",
      "properties" => {
        "test_attribute" => {
          "title" => "Test attribute",
          "type" => "string",
        },
      },
    }
    content = { "test_attribute" => "some text" }
    page = FlexiblePage.new
    page.flexible_page_content = content

    payload_builder = PublishingApi::PayloadBuilder::FlexiblePageContent.new(test_schema, page)

    assert_equal({ test_attribute: "some text" }, payload_builder.call)
  end

  test "it presents nested fields" do
    test_schema = {
      "$schema" => "https://json-schema.org/draft/2020-12/schema",
      "$id" => "https://www.gov.uk/schemas/test_type/v1",
      "title" => "Test type",
      "type" => "object",
      "properties" => {
        "test_object_attribute" => {
          "title" => "Test attribute",
          "type" => "object",
          "properties" => {
            "test_attribute_one" => {
              "type" => "string",
            },
            "test_attribute_two" => {
              "type" => "string",
            },
          },
        },
      },
    }
    content = { "test_object_attribute" => {
      "test_attribute_one" => "foo",
      "test_attribute_two" => "bar",
    } }
    page = FlexiblePage.new
    page.flexible_page_content = content

    payload_builder = PublishingApi::PayloadBuilder::FlexiblePageContent.new(test_schema, page)

    assert_equal({ test_object_attribute: {
      test_attribute_one: "foo",
      test_attribute_two: "bar",
    } }, payload_builder.call)
  end

  test "it renders govspeak fields into html" do
    test_schema = {
      "$schema" => "https://json-schema.org/draft/2020-12/schema",
      "$id" => "https://www.gov.uk/schemas/test_type/v1",
      "title" => "Test type",
      "type" => "object",
      "properties" => {
        "test_attribute" => {
          "title" => "Test attribute",
          "type" => "string",
          "format" => "govspeak",
        },
      },
    }
    govspeak = "## Some Govspeak\n\n%A callout%"
    html = "<h3>Some govspeak</h3><p class=\"govuk-callout\">A callout</p>"
    content = {
      "test_attribute" => govspeak,
    }
    page = FlexiblePage.new
    page.flexible_page_content = content
    govspeak_renderer = mock("Whitehall::GovspeakRenderer")
    govspeak_renderer
      .expects(:govspeak_to_html)
      .with(govspeak)
      .returns(html)

    Whitehall::GovspeakRenderer.expects(:new).returns(govspeak_renderer)
    payload_builder = PublishingApi::PayloadBuilder::FlexiblePageContent.new(test_schema, page)

    assert_equal({ test_attribute: html }, payload_builder.call)
  end

  test "it presents image select fields" do
    test_schema = {
      "$schema" => "https://json-schema.org/draft/2020-12/schema",
      "$id" => "https://www.gov.uk/schemas/test_type/v1",
      "title" => "Test type",
      "type" => "object",
      "properties" => {
        "test_attribute" => {
          "title" => "Test attribute",
          "type" => "string",
          "format" => "image_select",
        },
      },
    }
    images = create_list(:image, 3)
    content = { "test_attribute" => images[1].id }
    page = FlexiblePage.new
    page.flexible_page_content = content
    page.images = images

    payload_builder = PublishingApi::PayloadBuilder::FlexiblePageContent.new(test_schema, page)

    assert_equal({ test_attribute: {
      src: images[1].url,
      caption: images[1].caption,
      alt_text: images[1].alt_text,
    } }, payload_builder.call)
  end
end
