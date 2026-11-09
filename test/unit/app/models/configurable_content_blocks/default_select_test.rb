require "test_helper"

class ConfigurableContentBlocks::DefaultSelectRenderingTest < ActionView::TestCase
  include ConfigurableContentBlockSharedTests

  setup do
    @field = {
      "title" => "Test attribute",
      "description" => "A test attribute",
      "block" => "default_select",
      "translatable" => true,
      "options" => [
        { "label" => "Option 1", "value" => "opt 1" },
        { "label" => "Option 2", "value" => "opt 2" },
      ],
      "attribute_path" => %w[block_content test_attribute],
    }
    @path = Path.new(%w[block_content test_attribute])
    @edition = StandardEdition.new(configurable_document_type: "test_type")
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", {
      "forms" => {
        "documents" => {
          "fields" => { "test_attribute" => @field },
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
    @block = ConfigurableContentBlocks::DefaultSelect.new(@edition, @field, @path)
  end

  test "it renders a select with the provided options" do
    render @block

    assert_dom "select[name='edition[block_content][test_attribute]']"
    @field["options"].each do |option|
      assert_dom "option", text: option["label"], value: option["value"]
    end
  end

  test "it renders a select with the selected option" do
    selected_option_value = @field["options"].last["value"]
    selected_option_label = @field["options"].last["label"]
    @edition.block_content = { "test_attribute" => selected_option_value }

    render @block

    assert_dom "select[name='edition[block_content][test_attribute]']"
    assert_dom "option[selected]", text: selected_option_label, value: selected_option_value
  end

  test "it renders the blank option with a custom label" do
    @field["blank_option_label"] = "Choose something"
    render @block

    assert_dom "option[value='']", text: "Choose something"
    @field["options"].each do |option|
      assert_dom "option", text: option["label"], value: option["value"]
    end
    @field["blank_option_label"] = nil
  end

  test "it displays validation errors" do
    messages = %w[foo bar]
    messages.each { |m| @edition.errors.add(:test_attribute, m) }

    render @block

    assert_dom ".govuk-error-message", text: "Error: #{messages.map { |m| "Test attribute #{m}" }.join}"
  end

  test "it does inherit from parent, if `inherit_from_parent` set and it is an empty field of a new edition" do
    selected_option = @field["options"].last

    selectors = [
      [
        "option[selected][value=\"#{selected_option['value']}\"]",
      ],
    ]

    fill_in_field_with_option = proc do |option|
      selected_option_value = option["value"]

      proc do |edition|
        edition.block_content = {
          "test_attribute" => selected_option_value,
        }
      end
    end

    it_correctly_inherits_from_parent(ConfigurableContentBlocks::DefaultSelect, @field, @path, selectors, fill_in_field_with_option.call(selected_option))
  end

  test "it does not inherit from parent, if `inherit_from_parent` set and it is an empty field of a saved edition" do
    selected_option = @field["options"].last

    selectors = [
      [
        "option[selected][value=\"#{selected_option['value']}\"]",
      ],
    ]

    fill_in_field_with_option = proc do |option|
      selected_option_value = option["value"]

      proc do |edition|
        edition.block_content = {
          "test_attribute" => selected_option_value,
        }
      end
    end

    it_does_not_inherit_from_parent(ConfigurableContentBlocks::DefaultSelect, @field, @path, selectors, fill_in_field_with_option.call(selected_option))
  end
end
