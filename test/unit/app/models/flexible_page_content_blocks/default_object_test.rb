require "test_helper"
class FlexiblePageContentBlocks::DefaultObjectTest < ActiveSupport::TestCase
  test "it builds the Publishing API payload for the nested content" do
    FlexiblePageContentBlocks::Context.create(FlexiblePage.new, nil)
    schema = {
      "type" => "object",
      "properties" => {
        "test_attribute" => {
          "type" => "string",
          "format" => "govspeak",
        },
        "test_object_attribute" => {
          "type" => "object",
          "properties" => {
            "test_string" => {
              "type" => "string",
            },
          },
        },
      },
    }
    content = {
      "test_attribute" => "## Foo",
      "test_object_attribute" => {
        "test_string" => "bar",
      },
    }
    payload = FlexiblePageContentBlocks::DefaultObject.new.publishing_api_payload(schema, content)
    assert_equal(Whitehall::GovspeakRenderer.new.govspeak_to_html(content["test_attribute"]), payload[:test_attribute])
    assert_equal(content["test_object_attribute"]["test_string"], payload[:test_object_attribute][:test_string])
  end
end

class FlexiblePageContentBlocks::DefaultObjectRenderingTest < ActionView::TestCase
  test "it renders a fieldset with the schema title as the legend containing the child attributes" do
    FlexiblePageContentBlocks::Context.create(FlexiblePage.new, view)
    schema = {
      "title" => "Test object",
      "type" => "object",
      "properties" => {
        "test_attribute" => {
          "title" => "Test attribute",
          "type" => "string",
        },
      },
      "required" => %w[test_attribute],
    }
    render html: FlexiblePageContentBlocks::DefaultObject.new.render(schema, {})
    assert_dom "legend", text: schema["title"]
    assert_dom "label", text: "#{schema['properties']['test_attribute']['title']} (required)"
  end
end
