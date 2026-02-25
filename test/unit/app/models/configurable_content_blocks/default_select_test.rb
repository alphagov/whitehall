require "test_helper"

class ConfigurableContentBlocks::DefaultSelectRenderingTest < ActionView::TestCase
  setup do
    @fields = {
      "test_attribute" => {
        "title" => "Test attribute",
        "description" => "A test attribute",
        "block" => "default_select",
        "options" => [
          { "label" => "Option 1", "value" => "opt 1" },
          { "label" => "Option 2", "value" => "opt 2" },
        ],
        "attribute_path" => %w[block_content test_attribute],
      },
    }
    @path = Path.new(%w[block_content test_attribute])
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", {
      "forms" => {
        "documents" => {
          "fields" => @schema,
        },
      },
      "schema" => {
        "attributes" => {
          "test_attribute" => {
            "type" => "string",
          },
        },
      },
    }))
  end

  test "it renders a select with the provided options" do
    block = ConfigurableContentBlocks::DefaultSelect.new(StandardEdition.new, @fields["test_attribute"], @path)

    render block

    assert_dom "select[name='edition[block_content][test_attribute]']"
    @fields["test_attribute"]["options"].each do |option|
      assert_dom "option", text: option["label"], value: option["value"]
    end
  end

  test "it renders a select with the selected option" do
    selected_option_value = @fields["test_attribute"]["options"].last["value"]
    selected_option_label = @fields["test_attribute"]["options"].last["label"]
    edition = StandardEdition.new(configurable_document_type: "test_type", block_content: { "test_attribute" => selected_option_value })
    block = ConfigurableContentBlocks::DefaultSelect.new(edition, @fields["test_attribute"], @path)

    render block, {
      schema: @fields["test_attribute"],
      content: selected_option_value,
      path: @path,
    }

    assert_dom "select[name='edition[block_content][test_attribute]']"
    assert_dom "option[selected]", text: selected_option_label, value: selected_option_value
  end

  test "it renders the blank option with a custom label" do
    @fields["test_attribute"]["blank_option_label"] = "Choose something"
    block = ConfigurableContentBlocks::DefaultSelect.new(StandardEdition.new, @fields["test_attribute"], @path)

    render block

    assert_dom "option[value='']", text: "Choose something"
    @fields["test_attribute"]["options"].each do |option|
      assert_dom "option", text: option["label"], value: option["value"]
    end
    @fields["test_attribute"]["blank_option_label"] = nil
  end

  test "it displays validation errors" do
    messages = %w[foo bar]
    edition = StandardEdition.new
    messages.each { |m| edition.errors.add(:test_attribute, m) }
    block = ConfigurableContentBlocks::DefaultSelect.new(edition, @fields["test_attribute"], @path)

    render block

    assert_dom ".govuk-error-message", text: "Error: #{messages.map { |m| "Test attribute #{m}" }.join}"
  end
end
