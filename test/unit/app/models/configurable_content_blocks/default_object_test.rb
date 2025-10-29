require "test_helper"
class ConfigurableContentBlocks::DefaultObjectTest < ActiveSupport::TestCase
  include GovspeakHelper
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
    page = StandardEdition.new
    factory = ConfigurableContentBlocks::Factory.new(page)
    payload = ConfigurableContentBlocks::DefaultObject.new(factory).publishing_api_payload(schema, content)
    assert_equal(govspeak_to_html(content["test_attribute"]), payload[:test_attribute])
    assert_equal(content["test_object_attribute"]["test_string"], payload[:test_object_attribute][:test_string])
  end
  test "it omits any missing block content from the Publishing API payload, unless it's lead image" do
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
        "test_lead_image_attribute" => {
          "type" => "integer",
          "title" => "Test attribute",
          "description" => "A test attribute",
          "format" => "lead_image_select",
        },
      },
    }
    content = {
      "test_object_attribute" => {
        "test_string" => "bar",
      },
    }
    page = StandardEdition.new
    factory = ConfigurableContentBlocks::Factory.new(page)
    payload = ConfigurableContentBlocks::DefaultObject.new(factory).publishing_api_payload(schema, content)
    assert_not payload.key?(:test_attribute)
    assert_equal(content["test_object_attribute"]["test_string"], payload[:test_object_attribute][:test_string])
    assert payload.key?(:test_lead_image_attribute)
  end
end

class ConfigurableContentBlocks::DefaultObjectRenderingTest < ActionView::TestCase
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
    }
    factory = ConfigurableContentBlocks::Factory.new(StandardEdition.new)
    block = ConfigurableContentBlocks::DefaultObject.new(factory)
    render block, { schema:, content: {}, path: Path.new }
    assert_dom "legend", text: schema["title"].to_s
    assert_dom "label", text: schema["properties"]["test_attribute"]["title"].to_s
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
    }
    factory = ConfigurableContentBlocks::Factory.new(StandardEdition.new)
    block = ConfigurableContentBlocks::DefaultObject.new(factory)
    render block, { schema:, content: {}, path: Path.new, required: false, root: true }
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

    factory = ConfigurableContentBlocks::Factory.new(StandardEdition.new)
    block = ConfigurableContentBlocks::DefaultObject.new(factory)
    render block, { schema:, content: {}, path: Path.new }
    assert_dom "label", text: schema["properties"]["test_attribute"]["title"]
    refute_dom "label", text: "#{schema['properties']['test_attribute']['title']} (required)"
  end

  test "it applies the required attribute to any child attributes validated for presence" do
    schema = {
      "title" => "Test object",
      "type" => "object",
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
    }
    factory = ConfigurableContentBlocks::Factory.new(StandardEdition.new)
    block = ConfigurableContentBlocks::DefaultObject.new(factory)
    render block, { schema:, content: {}, path: Path.new }
    assert_dom "label", text: "#{schema['properties']['test_attribute']['title']} (required)"
  end

  test "it passes the right_to_left attribute on to child blocks" do
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
    factory = ConfigurableContentBlocks::Factory.new(StandardEdition.new)
    block = ConfigurableContentBlocks::DefaultObject.new(factory)
    render block, { schema:, content: {}, path: Path.new, right_to_left: true }
    assert_dom "label", text: schema["properties"]["test_attribute"]["title"].to_s
    assert_dom "input[dir=\"rtl\"]"
  end

  test "it passes the errors attribute on to child blocks" do
    schema = {
      "title" => "Test object",
      "type" => "object",
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
    }

    errors = [mock("object"), mock("object")]
    messages = %w[foo bar]
    errors.each_with_index do |error, index|
      error.expects(:attribute).returns(:test_attribute)
      error.expects(:full_message).returns(messages[index])
    end

    edition = build(:draft_standard_edition, { block_content: { "test_attribute": "" } })
    factory = ConfigurableContentBlocks::Factory.new(edition)
    block = ConfigurableContentBlocks::DefaultObject.new(factory)
    render block, { schema:, content: {}, path: Path.new, right_to_left: true, errors: }
    assert_dom ".govuk-error-message", "Error: #{messages.join}"
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
    factory = ConfigurableContentBlocks::Factory.new(StandardEdition.new)
    block = ConfigurableContentBlocks::DefaultObject.new(factory)
    render block, { schema:, content:, path: Path.new }
    assert_dom "input[name=?][value=?]", "edition[block_content][not_nested_attribute]", "bar"
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
    factory = ConfigurableContentBlocks::Factory.new(StandardEdition.new)
    block = ConfigurableContentBlocks::DefaultObject.new(factory)
    render block, { schema:, content:, path: Path.new }
    assert_dom "input[name=?][value=?]", "edition[block_content][test_object_attribute][nested_attribute]", "foo"
  end
end
