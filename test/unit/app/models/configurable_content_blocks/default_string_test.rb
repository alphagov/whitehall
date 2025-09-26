require "test_helper"

class ConfigurableContentBlocks::DefaultStringTest < ActiveSupport::TestCase
  test "it presents the content" do
    payload = ConfigurableContentBlocks::DefaultString.new.publishing_api_payload("foo")
    assert_equal("foo", payload)
  end
end

class ConfigurableContentBlocks::DefaultStringRenderingTest < ActionView::TestCase
  setup do
    @schema = {
      "type" => "object",
      "properties" => {
        "test_attribute" => {
          "type" => "string",
          "title" => "Test attribute",
          "description" => "A test attribute",
        },
      },
    }

    @page = StandardEdition.new
    @page.block_content = { "test_attribute" => "foo" }
    @block = ConfigurableContentBlocks::DefaultString.new
  end

  test "the form label is equal to the attribute title" do
    render @block, {
      schema: @schema["properties"]["test_attribute"],
      content: @page.block_content["test_attribute"],
      path: Path.new.push("test_attribute"),
    }
    assert_dom "label", text: @schema["properties"]["test_attribute"]["title"]
  end

  test "it adds a required message to the label when the attribute is required" do
    render @block, {
      schema: @schema["properties"]["test_attribute"],
      content: @page.block_content["test_attribute"],
      path: Path.new.push("test_attribute"),
      required: true,
    }
    assert_dom "label", text: "#{@schema['properties']['test_attribute']['title']} (required)"
  end

  test "it sets the input name correctly" do
    render @block, {
      schema: @schema["properties"]["test_attribute"],
      content: @page.block_content["test_attribute"],
      path: Path.new.push("test_attribute"),
    }
    assert_dom "input[name=?]", "edition[block_content][test_attribute]"
  end

  test "it sets the input value based on the content" do
    render @block, {
      schema: @schema["properties"]["test_attribute"],
      content: @page.block_content["test_attribute"],
      path: Path.new.push("test_attribute"),
    }
    assert_dom "input[value=?]", @page.block_content["test_attribute"]
  end

  test "it sets the hint text based on the description" do
    render @block, {
      schema: @schema["properties"]["test_attribute"],
      content: @page.block_content["test_attribute"],
      path: Path.new.push("test_attribute"),
    }
    assert_dom ".govuk-hint", text: @schema["properties"]["test_attribute"]["description"]
  end

  test "it sets the direction on the input to right to left when the rtl option returns true" do
    render @block, {
      schema: @schema["properties"]["test_attribute"],
      content: @page.block_content["test_attribute"],
      path: Path.new.push("test_attribute"),
      right_to_left: true,
    }
    assert_dom "input[dir=\"rtl\"]"
  end

  test "it renders the primary locale content under the input when the translated content is provided" do
    render @block, {
      schema: @schema["properties"]["test_attribute"],
      content: @page.block_content["test_attribute"],
      path: Path.new.push("test_attribute"),
      translated_content: "bar",
    }

    assert_dom ".govuk-details__text", text: @page.block_content["test_attribute"]
  end

  test "it sets the value of the textarea to the translated content when the translated content is provided" do
    render @block, {
      schema: @schema["properties"]["test_attribute"],
      content: @page.block_content["test_attribute"],
      path: Path.new.push("test_attribute"),
      translated_content: "bar",
    }

    assert_dom "input[value=?]", "bar"
  end
end
