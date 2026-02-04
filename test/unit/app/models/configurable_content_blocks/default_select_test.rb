require "test_helper"

class ConfigurableContentBlocks::DefaultSelectRenderingTest < ActionView::TestCase
  setup do
    @schema = {
      "test_attribute" => {
        "title" => "Test attribute",
        "description" => "A test attribute",
        "block" => "default_select",
        "options" => [
          { "label" => "Option 1", "value" => "opt 1" },
          { "label" => "Option 2", "value" => "opt 2" },
        ],
      },
    }
    @path = Path.new(%w[test_attribute])
  end

  test "it renders a select with the provided options" do
    block = ConfigurableContentBlocks::DefaultSelect.new

    render block, {
      schema: @schema["test_attribute"],
      content: nil,
      path: @path,
    }

    assert_dom "select[name='edition[block_content][test_attribute]']"
    @schema["test_attribute"]["options"].each do |option|
      assert_dom "option", text: option["label"], value: option["value"]
    end
  end

  test "it renders a select with the selected option" do
    block = ConfigurableContentBlocks::DefaultSelect.new
    selected_option_value = @schema["test_attribute"]["options"].last["value"]
    selected_option_label = @schema["test_attribute"]["options"].last["label"]

    render block, {
      schema: @schema["test_attribute"],
      content: selected_option_value,
      path: @path,
    }

    assert_dom "select[name='edition[block_content][test_attribute]']"
    assert_dom "option[selected]", text: selected_option_label, value: selected_option_value
  end

  test "it uses the translated content value when provided" do
    block = ConfigurableContentBlocks::DefaultSelect.new
    selected_option_value = @schema["test_attribute"]["options"].first["value"]
    selected_option_label = @schema["test_attribute"]["options"].first["label"]

    render block, {
      schema: @schema["test_attribute"],
      content: nil,
      translated_content: selected_option_value,
      path: @path,
    }

    assert_dom "select[name='edition[block_content][test_attribute]']"
    assert_dom "option[selected]", text: selected_option_label, value: selected_option_value
  end

  test "it renders the blank option with a custom label" do
    block = ConfigurableContentBlocks::DefaultSelect.new
    @schema["test_attribute"]["blank_option_label"] = "Choose something"

    render block, {
      schema: @schema["test_attribute"],
      content: nil,
      path: @path,
    }

    assert_dom "option[value='']", text: "Choose something"
    @schema["test_attribute"]["options"].each do |option|
      assert_dom "option", text: option["label"], value: option["value"]
    end
  end

  test "it displays validation errors" do
    block = ConfigurableContentBlocks::DefaultSelect.new
    errors = [mock("object"), mock("object")]
    messages = %w[foo bar]
    errors.each_with_index do |error, index|
      error.expects(:attribute).returns(:test_attribute)
      error.expects(:full_message).returns(messages[index])
    end

    render block, {
      schema: @schema["test_attribute"],
      content: nil,
      path: @path,
      errors: errors,
    }

    assert_dom ".govuk-error-message", text: "Error: #{messages.join}"
  end
end
