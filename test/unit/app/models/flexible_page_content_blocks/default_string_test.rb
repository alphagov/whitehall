require "test_helper"

class FlexiblePageContentBlocks::DefaultStringTest < ActiveSupport::TestCase
  test "it presents the content" do
    FlexiblePageContentBlocks::Context.create_for_page(FlexiblePage.new)
    payload = FlexiblePageContentBlocks::DefaultString.new.publishing_api_payload("foo")
    assert_equal("foo", payload)
  end
end

class FlexiblePageContentBlocks::DefaultStringRenderingTest < ActionView::TestCase
  setup do
    @schema = {
      "type" => "object",
      "properties" => {
        "test_attribute" => {
          "type" => "string",
          "title" => "Test attribute",
          "description" => "A test attribute",
        },
      },
    }

    @page = FlexiblePage.new
    FlexiblePageContentBlocks::Context.create_for_page(@page)
    @page.flexible_page_content = { "test_attribute" => "foo" }
    @block = FlexiblePageContentBlocks::DefaultString.new
  end

  test "the form label is equal to the attribute title" do
    render partial: @block.to_partial_path, locals: {
      schema: @schema["properties"]["test_attribute"],
      content: @page.flexible_page_content["test_attribute"],
      path: Path.new.push("test_attribute"),
    }
    assert_dom "label", text: @schema["properties"]["test_attribute"]["title"]
  end

  test "it adds a required message to the label when the attribute is required" do
    render partial: @block.to_partial_path, locals: {
      schema: @schema["properties"]["test_attribute"],
      content: @page.flexible_page_content["test_attribute"],
      path: Path.new.push("test_attribute"),
      required: true,
    }
    assert_dom "label", text: "#{@schema['properties']['test_attribute']['title']} (required)"
  end

  test "it sets the input name correctly" do
    render partial: @block.to_partial_path, locals: {
      schema: @schema["properties"]["test_attribute"],
      content: @page.flexible_page_content["test_attribute"],
      path: Path.new.push("test_attribute"),
    }
    assert_dom "input[name=?]", "edition[flexible_page_content][test_attribute]"
  end

  test "it sets the input value based on the content" do
    render partial: @block.to_partial_path, locals: {
      schema: @schema["properties"]["test_attribute"],
      content: @page.flexible_page_content["test_attribute"],
      path: Path.new.push("test_attribute"),
    }
    assert_dom "input[value=?]", @page.flexible_page_content["test_attribute"]
  end

  test "it sets the hint text based on the description" do
    render partial: @block.to_partial_path, locals: {
      schema: @schema["properties"]["test_attribute"],
      content: @page.flexible_page_content["test_attribute"],
      path: Path.new.push("test_attribute"),
    }
    assert_dom ".govuk-hint", text: @schema["properties"]["test_attribute"]["description"]
  end
end
