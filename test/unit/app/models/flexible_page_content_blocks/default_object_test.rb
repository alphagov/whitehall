require "test_helper"
class FlexiblePageContentBlocks::DefaultObjectTest < ActiveSupport::TestCase
  test "it builds the Publishing API payload for the nested content" do
    schema = {
      "type" => "object",
      "properties" => {
        "test_attribute" => {
          "type" => "string",
          "format" => "govspeak",
        },
        "test_object_attribute" => {
          "type" => "object",
          "properties" => {
            "test_string" => {
              "type" => "string",
            },
          },
        },
      },
    }
    content = {
      "test_attribute" => "## Foo",
      "test_object_attribute" => {
        "test_string" => "bar",
      },
    }
    payload = FlexiblePageContentBlocks::DefaultObject.new.publishing_api_payload(schema, content)
    assert_equal(Whitehall::GovspeakRenderer.new.govspeak_to_html(content["test_attribute"]), payload[:test_attribute])
    assert_equal(content["test_object_attribute"]["test_string"], payload[:test_object_attribute][:test_string])
  end
end

class FlexiblePageContentBlocks::DefaultObjectRenderingTest < ActionView::TestCase
  test "it renders a fieldset with the schema title as the legend containing the child attributes" do
    schema = {
      "title" => "Test object",
      "type" => "object",
      "properties" => {
        "test_attribute" => {
          "title" => "Test attribute",
          "type" => "string",
        },
      },
      "required" => %w[test_attribute],
    }
    render partial: "admin/flexible_pages/content_blocks/default_object", locals: { schema:, content: {}, path: Path.new, required: true }
    assert_dom "legend", text: "#{schema['title']} (required)"
    assert_dom "label", text: "#{schema['properties']['test_attribute']['title']} (required)"
  end

  test "it does not render a fieldset with the schema title as the legend for the root object" do
    schema = {
      "title" => "Test object",
      "type" => "object",
      "properties" => {
        "test_attribute" => {
          "title" => "Test attribute",
          "type" => "string",
        },
      },
      "required" => %w[test_attribute],
    }
    render partial: "admin/flexible_pages/content_blocks/default_object", locals: { schema:, content: {}, path: Path.new, required: false, root: true }
    refute_dom "legend", text: schema["title"]
  end

  test "it renders non-required child attribute" do
    schema = {
      "title" => "Test object",
      "type" => "object",
      "properties" => {
        "test_attribute" => {
          "title" => "Test attribute",
          "type" => "string",
        },
      },
    }

    render partial: "admin/flexible_pages/content_blocks/default_object", locals: { schema:, content: {}, path: Path.new }
    assert_dom "label", text: schema["properties"]["test_attribute"]["title"]
    refute_dom "label", text: "#{schema['properties']['test_attribute']['title']} (required)"
  end

  test "it passes the required attribute on to any required child attributes" do
    schema = {
      "title" => "Test object",
      "type" => "object",
      "properties" => {
        "test_attribute" => {
          "title" => "Test attribute",
          "type" => "string",
        },
      },
      "required" => %w[test_attribute],
    }
    render partial: "admin/flexible_pages/content_blocks/default_object", locals: { schema:, content: {}, path: Path.new }
    assert_dom "label", text: "#{schema['properties']['test_attribute']['title']} (required)"
  end

  test "it renders not-nested child attribute content" do
    schema = {
      "title" => "Test object",
      "type" => "object",
      "properties" => {
        "not_nested_attribute" => {
          "title" => "Not nested attribute",
          "type" => "string",
        },
      },
    }
    content = { "not_nested_attribute" => "bar" }
    render partial: "admin/flexible_pages/content_blocks/default_object", locals: { schema:, content:, path: Path.new }
    assert_dom "input[name=?][value=?]", "edition[flexible_page_content][not_nested_attribute]", "bar"
  end

  test "it renders nested child attribute content" do
    schema = {
      "title" => "Test object",
      "type" => "object",
      "properties" => {
        "test_object_attribute" => {
          "title" => "Test attribute",
          "type" => "object",
          "properties" => {
            "nested_attribute" => {
              "title" => "Nested attribute",
              "type" => "string",
            },
          },
        },
      },
    }
    content = { "test_object_attribute" => { "nested_attribute" => "foo" } }
    render partial: "admin/flexible_pages/content_blocks/default_object", locals: { schema:, content:, path: Path.new }
    assert_dom "input[name=?][value=?]", "edition[flexible_page_content][test_object_attribute][nested_attribute]", "foo"
  end
end
