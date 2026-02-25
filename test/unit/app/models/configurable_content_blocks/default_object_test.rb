require "test_helper"

class ConfigurableContentBlocks::DefaultObjectRenderingTest < ActionView::TestCase
  setup do
    @schema = {
      "title" => "Test object",
      "block" => "default_object",
      "fields" => {
        "test_attribute" => {
          "title" => "Test attribute",
          "block" => "default_string",
          "attribute_path" => %w[block_content test_attribute],
        },
      },
    }
  end

  test "it renders a fieldset with the schema title as the legend containing the child attributes" do
    edition = StandardEdition.new
    block = ConfigurableContentBlocks::DefaultObject.new(edition, @schema, Path.new)
    render block
    assert_dom "legend", text: @schema["title"].to_s
    assert_dom "label", text: @schema["fields"]["test_attribute"]["title"].to_s
  end

  test "it renders a fieldset with the required label applied to the legend" do
    edition = StandardEdition.new
    block = ConfigurableContentBlocks::DefaultObject.new(edition, @schema.merge("required" => true), Path.new)
    render block
    assert_dom "legend", text: "#{@schema['title']} (required)"
  end

  test "it does not render a fieldset with the schema title as the legend for the root object" do
    edition = StandardEdition.new
    block = ConfigurableContentBlocks::DefaultObject.new(edition, @schema.merge("root" => true), Path.new)
    render block
    refute_dom "legend", text: @schema["title"]
  end
end
