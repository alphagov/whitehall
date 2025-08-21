require "test_helper"
class ConfigurableContentBlocks::GovspeakTest < ActiveSupport::TestCase
  test "it validates that the content is a string" do
    validator = ConfigurableContentBlocks::Govspeak.new.json_schema_validator
    assert_not validator.call(5)
  end

  test "it validates that the content is valid govspeak" do
    validator = ConfigurableContentBlocks::Govspeak.new.json_schema_validator
    assert_not validator.call("<script>alert('You've been pwned!')</script>'")
  end

  test "it presents the govspeak content as HTML, including images" do
    image = create(:image)
    govspeak = "A paragraph followed by an image:\n[Image: #{image.filename}]"
    content = {
      "test_attribute" => govspeak,
    }
    page = StandardEdition.new
    page.images = [image]
    page.block_content = content
    payload = ConfigurableContentBlocks::Govspeak.new(page.images).publishing_api_payload(govspeak)
    assert_match(/A paragraph followed by an image|img src|#{Regexp.escape(image.url)}/, payload[:html])
  end

  test "it includes headers in the payload, if present in the govspeak" do
    govspeak = "## Some header\n\n%A callout%"
    html = "<h3>Some header</h3><p class=\"govuk-callout\">A callout</p>"
    content = {
      "test_attribute" => govspeak,
    }
    page = StandardEdition.new
    page.block_content = content
    govspeak_renderer = mock("Whitehall::GovspeakRenderer")
    govspeak_renderer
      .expects(:govspeak_to_html_with_images_and_attachments)
      .with(govspeak, [])
      .returns(html)
    expected_headers = [
      {
        text: "Some header",
        level: 2,
        id: "some-header",
      },
    ]
    Whitehall::GovspeakRenderer.stub :new, govspeak_renderer do
      payload = ConfigurableContentBlocks::Govspeak.new.publishing_api_payload(govspeak)
      assert_equal expected_headers, payload[:headers]
      assert_not_nil payload[:html]
    end
  end

  test "it does not include headers in the payload, if not present in the govspeak" do
    govspeak = "Some content without headers"
    html = "Some content without headers"
    content = {
      "test_attribute" => govspeak,
    }
    page = StandardEdition.new
    page.block_content = content
    govspeak_renderer = mock("Whitehall::GovspeakRenderer")
    govspeak_renderer
      .expects(:govspeak_to_html_with_images_and_attachments)
      .with(govspeak, [])
      .returns(html)
    Whitehall::GovspeakRenderer.stub :new, govspeak_renderer do
      payload = ConfigurableContentBlocks::Govspeak.new.publishing_api_payload(govspeak)
      assert_nil payload[:headers]
      assert_not_nil payload[:html]
    end
  end
end

class ConfigurableContentBlocks::GovspeakRenderingTest < ActionView::TestCase
  test "it renders a textarea" do
    schema = {
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

    page = StandardEdition.new
    page.block_content = { "test_attribute" => "## foo" }
    block = ConfigurableContentBlocks::Govspeak.new

    render block, {
      schema: schema["properties"]["test_attribute"],
      content: page.block_content["test_attribute"],
      path: Path.new.push("test_attribute"),
    }
    assert_dom "textarea[name=?]", "edition[block_content][test_attribute]", text: page.block_content["test_attribute"]
  end
end
