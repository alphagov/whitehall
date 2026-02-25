require "test_helper"

class ConfigurableContentBlocks::DefaultArrayRenderingTest < ActionView::TestCase
  test "it renders a fieldset with the schema title as the main legend, followed by a secondary legend for each item" do
    schema = {
      "title" => "List of foods",
      "block" => "default_array",
      "fields" => {
        "food" => {
          "title" => "Name of food",
          "block" => "default_string",
        },
      },
    }
    setup_type("list_of_foods", schema)
    block = ConfigurableContentBlocks::DefaultArray.new(StandardEdition.new, schema, Path.new(%w[list_of_foods]))
    render block
    assert_dom "legend.govuk-fieldset__legend--l", text: "List of foods"
    assert_dom "legend.govuk-fieldset__legend--m", text: "List of foods 1"
    assert_dom "label[for=edition_list_of_foods_0_food]", text: "Name of food"
    assert_dom "input#edition_list_of_foods_0_food"
  end

  test "it includes a 'Remove' checkbox for the first empty item, so that noJS users can 'remove' the empty element before submitting the form" do
    schema = {
      "title" => "List of foods",
      "block" => "default_array",
      "fields" => {
        "food" => {
          "title" => "Name of food",
          "block" => "default_string",
        },
      },
    }
    setup_type("list_of_foods", schema)
    block = ConfigurableContentBlocks::DefaultArray.new(StandardEdition.new, schema, Path.new(%w[list_of_foods]))
    render block
    assert_dom "input[type=checkbox][name='edition[block_content][list_of_foods][0][_destroy]']"
    assert_dom "label.govuk-checkboxes__label", text: "Remove"
  end

  test "it prepopulates existing items and includes an 'empty' item at the end" do
    schema = {
      "title" => "List of foods",
      "block" => "default_array",
      "fields" => {
        "food" => {
          "title" => "Name of food",
          "block" => "default_string",
        },
      },
    }
    setup_type("list_of_foods", schema)
    edition = StandardEdition.new(
      configurable_document_type: "array_type",
      block_content: {
        "list_of_foods" => [
          { "food" => "Apples" },
          { "food" => "Bananas" },
        ],
      },
    )
    block = ConfigurableContentBlocks::DefaultArray.new(edition, schema, Path.new(%w[list_of_foods]))
    render block
    assert_dom "input#edition_list_of_foods_0_food[value='Apples']"
    assert_dom "input#edition_list_of_foods_1_food[value='Bananas']"
    assert_dom "input#edition_list_of_foods_2_food", text: ""
  end

  test "it renders translated content" do
    schema = {
      "title" => "List of foods",
      "block" => "default_array",
      "fields" => {
        "food" => {
          "title" => "Name of food",
          "block" => "default_string",
        },
      },
    }
    setup_type("list_of_foods", schema)
    edition = StandardEdition.new(
      configurable_document_type: "array_type",
      block_content: {
        "list_of_foods" => [
          { "food" => "Apples" },
        ],
      },
    )
    with_locale(:es) do
      edition.block_content = {
        "list_of_foods" => [
          { "food" => "Manzanas" },
        ],
      }
      block = ConfigurableContentBlocks::DefaultArray.new(edition, schema, Path.new(%w[list_of_foods]))
      render block
    end
    assert_dom "input#edition_list_of_foods_0_food[value='Manzanas']"
    refute_dom "input#edition_list_of_foods_0_food[value='Apples']"
  end

  test "it renders whatever field type is specified in the schema for each item" do
    schema = {
      "title" => "List of publish dates",
      "block" => "default_array",
      "fields" => {
        "publish_date" => {
          "title" => "Publish date",
          "block" => "default_date",
        },
      },
    }
    setup_type("list_of_publish_dates", schema)
    block = ConfigurableContentBlocks::DefaultArray.new(StandardEdition.new, schema, Path.new(%w[list_of_publish_dates]))
    render block
    assert_dom "legend.govuk-fieldset__legend--l", text: "List of publish dates"
    assert_dom "legend.govuk-fieldset__legend--m", text: "List of publish dates 1"
    assert_dom ".govuk-hint", text: "For example, 01 08 2015"
    assert_dom "input[name='edition[block_content][list_of_publish_dates][0][publish_date][3]']" # Day
    assert_dom "input[name='edition[block_content][list_of_publish_dates][0][publish_date][2]']" # Month
    assert_dom "input[name='edition[block_content][list_of_publish_dates][0][publish_date][1]']" # Year
  end

  def setup_type(key, field)
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("array_type", {
      "forms" => {
        "documents" => {
          "fields" => {
            key => field,
          },
        },
      },
      "schema" => {
        "attributes" => {
          "list_of_foods" => {
            "type" => "array",
            "attributes" => {
              "food" => {
                "type" => "string",
              },
            },
          },
          "list_of_publish_dates" => {
            "type" => "array",
            "attributes" => {
              "publish_date" => {
                "type" => "date",
              },
            },
          },
        },
      },
    }))
  end
end
