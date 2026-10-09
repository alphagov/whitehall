require "test_helper"

class ConfigurableContentBlocks::DefaultCheckboxesRenderingTest < ActionView::TestCase
  include ConfigurableContentBlockSharedTests

  ITEMS = [
    { "label" => "Option one", "value" => "one" },
    { "label" => "Option two", "value" => "two" },
    {
      "label" => "Option three",
      "value" => "three",
      "conditionally_reveal" => [
        {
          "title" => "Details for option three",
          "block" => "default_string",
          "attribute_path" => %w[details],
          "translatable" => false,
        },
      ],
    },
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

  test "it renders the conditionally_reveal fields for items that have them, but not for items without" do
    render @block

    assert_dom "input[name='edition[block_content][choices][three][details]']"
    assert_dom "label", text: "Details for option three"
    assert_dom "input[name='edition[block_content][choices][one][details]']", count: 0
    assert_dom "input[name='edition[block_content][choices][two][details]']", count: 0
  end

  test "it pre-fills the conditionally revealed field with the currently stored value" do
    @edition.block_content = {
      "choices" => {
        "selected" => %w[three],
        "three" => { "details" => "Some extra detail" },
      },
    }

    render @block

    assert_dom "input[name='edition[block_content][choices][three][details]'][value='Some extra detail']"
  end

  test "it displays validation errors for an individual conditionally revealed field" do
    @edition.errors.add(:"choices.three.details", "is not valid")

    render @block

    assert_dom "input#edition_choices_three_details.govuk-input--error"
    assert_dom ".govuk-error-message", text: /is not valid/
  end
end
