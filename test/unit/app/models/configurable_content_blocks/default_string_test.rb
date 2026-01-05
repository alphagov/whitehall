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
      "block" => "default_object",
      "fields" => {
        "test_attribute" => {
          "block" => "default_string",
          "title" => "Test attribute",
          "description" => "A test attribute",
        },
      },
    }
    @block_content = { "test_attribute" => "foo" }
    @block = ConfigurableContentBlocks::DefaultString.new
    @path = Path.new(%w[test_attribute])
  end

  test "the form label is equal to the attribute title" do
    render @block, {
      schema: @schema["fields"]["test_attribute"],
      content: @block_content["test_attribute"],
      path: @path,
    }
    assert_dom "label", text: @schema["fields"]["test_attribute"]["title"]
  end

  test "it adds a required message to the label when the attribute is required" do
    render @block, {
      schema: @schema["fields"]["test_attribute"],
      content: @block_content["test_attribute"],
      path: @path,
      required: true,
    }
    assert_dom "label", text: "#{@schema['fields']['test_attribute']['title']} (required)"
  end

  test "it sets the input name correctly" do
    render @block, {
      schema: @schema["fields"]["test_attribute"],
      content: @block_content["test_attribute"],
      path: @path,
    }
    assert_dom "input[name=?]", "edition[block_content][test_attribute]"
  end

  test "it sets the input value based on the content" do
    render @block, {
      schema: @schema["fields"]["test_attribute"],
      content: @block_content["test_attribute"],
      path: @path,
    }
    assert_dom "input[value=?]", @block_content["test_attribute"]
  end

  test "it sets the hint text based on the description" do
    render @block, {
      schema: @schema["fields"]["test_attribute"],
      content: @block_content["test_attribute"],
      path: @path,
    }
    assert_dom ".govuk-hint", text: @schema["fields"]["test_attribute"]["description"]
  end

  test "it sets the direction on the input to right to left when the rtl option returns true" do
    render @block, {
      schema: @schema["fields"]["test_attribute"],
      content: @block_content["test_attribute"],
      path: @path,
      right_to_left: true,
    }
    assert_dom "input[dir=\"rtl\"]"
  end

  test "it renders the primary locale content under the input when the translated content is provided" do
    render @block, {
      schema: @schema["fields"]["test_attribute"],
      content: @block_content["test_attribute"],
      path: @path,
      translated_content: "bar",
    }

    assert_dom ".govuk-details__text", text: @block_content["test_attribute"]
  end

  test "it sets the value of the textarea to the translated content when the translated content is provided" do
    render @block, {
      schema: @schema["fields"]["test_attribute"],
      content: @block_content["test_attribute"],
      path: @path,
      translated_content: "bar",
    }

    assert_dom "input[value=?]", "bar"
  end

  test "it renders any validation errors when they are present" do
    errors = [mock("object"), mock("object")]
    messages = %w[foo bar]
    errors.each_with_index do |error, index|
      error.expects(:attribute).returns(:test_attribute)
      error.expects(:full_message).returns(messages[index])
    end

    render @block, {
      schema: @schema["fields"]["test_attribute"],
      content: @block_content["test_attribute"],
      path: @path,
      errors:,
    }
    assert_dom ".govuk-error-message", "Error: #{messages.join}"
  end
end
