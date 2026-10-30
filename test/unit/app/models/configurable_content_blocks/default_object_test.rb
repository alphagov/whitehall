require "test_helper"

class ConfigurableContentBlocks::DefaultObjectRenderingTest < ActionView::TestCase
  include ConfigurableContentBlockSharedTests

  setup do
    @field = {
      "title" => "Test object",
      "block" => "default_object",
      "translatable" => true,
      "attribute_path": [],
      "fields" => {
        "test_attribute" => {
          "title" => "Test attribute",
          "block" => "default_string",
          "attribute_path" => %w[block_content test_attribute],
          "translatable" => true,
        },
      },
    }
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", {
      "forms" => {
        "documents" => {
          "fields" => {
            "test_attribute" => @field,
          },
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
    @path = Path.new
    @edition = StandardEdition.new(configurable_document_type: "test_type")
  end

  test "it renders a fieldset with the schema title as the legend containing the child attributes" do
    render block
    assert_dom "legend", text: @field["title"].to_s
    assert_dom "label", text: @field["fields"]["test_attribute"]["title"].to_s
  end

  test "it renders a fieldset with the required label applied to the legend" do
    @field["required"] = true
    render block
    assert_dom "legend", text: "#{@field['title']} (required)"
  end

  test "it does not render a fieldset with the schema title as the legend for the root object" do
    @field["root"] = true
    render block
    refute_dom "legend", text: @field["title"]
  end

  def block
    ConfigurableContentBlocks::DefaultObject.new(@edition, @field, @path)
  end

  def field_with_value
    [
      "input[value=\"Title\"]",
    ]
  end

  def fill_in_field(edition)
    edition ||= @edition

    edition.block_content = {
      "test_attribute" => "Title",
    }
  end
end
