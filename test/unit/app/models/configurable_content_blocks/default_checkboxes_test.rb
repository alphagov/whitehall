require "test_helper"

class ConfigurableContentBlocks::DefaultCheckboxesRenderingTest < ActionView::TestCase
  include ConfigurableContentBlockSharedTests

  ITEMS = [
    { "label" => "Option one", "value" => "one" },
    { "label" => "Option two", "value" => "two" },
    { "label" => "Option three", "value" => "three" },
  ].freeze

  setup do
    @field = {
      "title" => "Choices",
      "required" => true,
      "block" => "default_checkboxes",
      "attribute_path" => %w[block_content choices],
      "translatable" => false,
      "items" => ITEMS,
    }
    @path = ConfigurableContentBlocks::Path.new(%w[block_content choices])
    @edition = StandardEdition.new(configurable_document_type: "test_type")
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", {
      "forms" => {
        "documents" => {
          "fields" => { "choices" => @field },
        },
      },
      "schema" => {
        "attributes" => {
          "choices" => {
            "type" => "object",
          },
        },
      },
    }))
    @block = ConfigurableContentBlocks::DefaultCheckboxes.new(@edition, @field, @path)
  end

  test "it renders a checkbox for each item" do
    render @block

    assert_dom "input[type=checkbox][name='edition[block_content][choices][selected][]'][value='one']"
    assert_dom "label", text: "Option one"
    assert_dom "input[type=checkbox][name='edition[block_content][choices][selected][]'][value='two']"
    assert_dom "label", text: "Option two"
    assert_dom "input[type=checkbox][name='edition[block_content][choices][selected][]'][value='three']"
    assert_dom "label", text: "Option three"
  end

  test "it renders the required label" do
    render @block

    assert_dom "legend, .govuk-fieldset__legend", text: /Choices \(required\)/
  end

  test "it checks the boxes for the currently selected values" do
    @edition.block_content = { "choices" => { "selected" => %w[two] } }

    render @block

    assert_dom "input[value='two'][checked]"
    assert_dom "input[value='one']:not([checked])"
    assert_dom "input[value='three']:not([checked])"
  end

  test "it displays validation errors" do
    @edition.errors.add(:choices, "- you must select an option")

    render @block

    assert_dom ".govuk-error-message"
  end
end
