require "test_helper"

class ConfigurableContentBlocks::DefaultObjectRenderingTest < ActionView::TestCase
  include ConfigurableContentBlockSharedTests

  setup do
    @field = {
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
    @path = Path.new
    @edition = StandardEdition.new
    @block = ConfigurableContentBlocks::DefaultObject.new(@edition, @field, @path)
  end

  test "it renders a fieldset with the schema title as the legend containing the child attributes" do
    render @block
    assert_dom "legend", text: @field["title"].to_s
    assert_dom "label", text: @field["fields"]["test_attribute"]["title"].to_s
  end

  test "it renders a fieldset with the required label applied to the legend" do
    @field["required"] = true
    @block = ConfigurableContentBlocks::DefaultObject.new(@edition, @field, @path)
    render @block
    assert_dom "legend", text: "#{@field['title']} (required)"
  end

  test "it does not render a fieldset with the schema title as the legend for the root object" do
    @field["root"] = true
    @block = ConfigurableContentBlocks::DefaultObject.new(@edition, @field, @path)
    render @block
    refute_dom "legend", text: @field["title"]
  end
end
