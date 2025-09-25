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

  test "it presents the govspeak content as HTML, including images and attachments" do
    image = create(:image)
    attachment = create(:file_attachment)
    govspeak = "A paragraph followed by an image:\n[Image: #{image.filename}]\n[Attachment: #{attachment.filename}]"
    content = {
      "test_attribute" => govspeak,
    }
    page = StandardEdition.new
    page.images = [image]
    page.attachments = [attachment]
    page.block_content = content
    payload = ConfigurableContentBlocks::Govspeak.new(page.images, page.attachments).publishing_api_payload(govspeak)
    doc = Nokogiri::HTML(payload[:html])
    assert_not doc.css("a[href=\"#{attachment.url}\"]").empty?
    assert_not doc.css("img[src=\"#{image.url}\"]").empty?
    assert_match(/A paragraph followed by an image/m, doc.text)
  end

  test "it includes headers in the payload, if present in the govspeak" do
    govspeak = "## Some header\n\n%A callout%"
    content = {
      "test_attribute" => govspeak,
    }
    page = StandardEdition.new
    page.block_content = content
    expected_headers = [
      {
        text: "Some header",
        level: 2,
        id: "some-header",
      },
    ]
    payload = ConfigurableContentBlocks::Govspeak.new.publishing_api_payload(govspeak)
    assert_equal expected_headers, payload[:headers]
    assert_not_nil payload[:html]
  end

  test "it does not include headers in the payload, if not present in the govspeak" do
    govspeak = "Some content without headers"
    content = {
      "test_attribute" => govspeak,
    }
    page = StandardEdition.new
    page.block_content = content
    payload = ConfigurableContentBlocks::Govspeak.new.publishing_api_payload(govspeak)
    assert_nil payload[:headers]
    assert_not_nil payload[:html]
  end
end

class ConfigurableContentBlocks::GovspeakRenderingTest < ActionView::TestCase
  test "it renders a govspeak editor with attachments and images for embedding" do
    file_attachment = create(:file_attachment)
    image = create(:image)
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
      "settings" => {
        "file_attachments_enabled" => true,
        "images_enabled" => true,
      },
    }

    govspeak_content = "## foo\n[Attachment: #{file_attachment.filename}]"
    block = ConfigurableContentBlocks::Govspeak.new([image], [file_attachment])

    render block, {
      schema: schema["properties"]["test_attribute"],
      content: govspeak_content,
      path: Path.new.push("test_attribute"),
    }

    assert_dom ".app-c-govspeak-editor[data-attachment-ids=\"[#{file_attachment.id}]\"][data-image-ids=\"[#{image.id}]\"]"
  end
end
