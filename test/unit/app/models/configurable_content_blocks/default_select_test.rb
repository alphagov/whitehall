require "test_helper"

class ConfigurableContentBlocks::DefaultSelectRenderingTest < ActionView::TestCase
  setup do
    @schema = {
      "test_attribute" => {
        "title" => "Test attribute",
        "description" => "A test attribute",
        "block" => "default_select",
        "options" => [
          { "label" => "Option 1", "value" => "opt1" },
          { "label" => "Option 2", "value" => "opt2" },
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
    assert_dom "option", text: "Option 1", value: "opt1"
    assert_dom "option", text: "Option 2", value: "opt2"
  end

  test "it renders a select with the selected option" do
    block = ConfigurableContentBlocks::DefaultSelect.new

    render block, {
      schema: @schema["test_attribute"],
      content: "opt2",
      path: @path,
    }

    assert_dom "select[name='edition[block_content][test_attribute]']"
    assert_dom "option[selected]", text: "Option 2", value: "opt2"
  end
end
