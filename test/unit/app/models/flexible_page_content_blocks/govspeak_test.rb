require "test_helper"
class FlexiblePageContentBlocks::GovspeakTest < ActiveSupport::TestCase
  test "it validates that the content is a string" do
    validator = FlexiblePageContentBlocks::Govspeak.new.json_schema_validator
    assert_not validator.call(5)
  end

  test "it validates that the content is valid govspeak" do
    validator = FlexiblePageContentBlocks::Govspeak.new.json_schema_validator
    assert_not validator.call("<script>alert('You've been pwned!')</script>'")
  end

  test "it presents the govspeak content as HTML" do
    govspeak = "## Some Govspeak\n\n%A callout%"
    html = "<h3>Some govspeak</h3><p class=\"govuk-callout\">A callout</p>"
    content = {
      "test_attribute" => govspeak,
    }
    page = FlexiblePage.new
    page.flexible_page_content = content
    govspeak_renderer = mock("Whitehall::GovspeakRenderer")
    govspeak_renderer
      .expects(:govspeak_to_html)
      .with(govspeak)
      .returns(html)
    Whitehall::GovspeakRenderer.stub :new, govspeak_renderer do
      payload = FlexiblePageContentBlocks::Govspeak.new.publishing_api_payload(govspeak)
      assert_equal html, payload
    end
  end
end

class FlexiblePageContentBlocks::GovspeakRenderingTest < ActionView::TestCase
  test "it renders a textarea" do
    @schema = {
      "type" => "object",
      "properties" => {
        "test_attribute" => {
          "type" => "string",
          "title" => "Test attribute",
          "description" => "A test attribute",
          "format" => "govspeak",
        },
      },
    }

    @page = FlexiblePage.new
    FlexiblePageContentBlocks::Context.create(@page, view)
    @page.flexible_page_content = { "test_attribute" => "## foo" }
    @block = FlexiblePageContentBlocks::Govspeak.new

    path = %w[test_attribute]
    render html: @block.render(
      @schema["properties"]["test_attribute"],
      @page.flexible_page_content["test_attribute"],
      path,
    )

    assert_dom "textarea[name=?]", "edition[flexible_page_content][#{path.join('][')}]", text: @page.flexible_page_content["test_attribute"]
  end
end
