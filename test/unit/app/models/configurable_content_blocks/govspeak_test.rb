require "test_helper"
class ConfigurableContentBlocks::GovspeakTest < ActiveSupport::TestCase
  test "it presents the govspeak content as HTML, including images and attachments" do
    image = create(:image)
    attachment = create(:file_attachment)
    govspeak = "A paragraph followed by an image:\n[Image: #{image.filename}]\n[Attachment: #{attachment.filename}]"
    images = [image]
    attachments = [attachment]
    payload = ConfigurableContentBlocks::Govspeak.new(images, attachments).publishing_api_payload(govspeak)
    doc = Nokogiri::HTML(payload)
    assert_not doc.css("a[href=\"#{attachment.url}\"]").empty?
    assert_not doc.css("img[src=\"#{image.url}\"]").empty?
    assert_match(/A paragraph followed by an image/m, doc.text)
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

  test "it sets the direction on the textarea to right to left when the rtl option returns true" do
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
    govspeak_content = "## foo"
    block = ConfigurableContentBlocks::Govspeak.new([], [])
    render block, {
      schema: schema["properties"]["test_attribute"],
      content: govspeak_content,
      path: Path.new.push("test_attribute"),
      right_to_left: true,
    }
    assert_dom ".app-c-govspeak-editor textarea[dir=\"rtl\"]"
  end

  test "it renders the primary locale content under the textarea when the translated content is provided" do
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
    govspeak_content = "## foo"
    block = ConfigurableContentBlocks::Govspeak.new([], [])
    render block, {
      schema: schema["properties"]["test_attribute"],
      content: govspeak_content,
      path: Path.new.push("test_attribute"),
      translated_content: "## bar",
    }
    assert_dom ".govuk-details__text", text: govspeak_content
  end

  test "it sets the value of the textarea to the translated content when the translated content is provided" do
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
    translated_content = "## foo"
    block = ConfigurableContentBlocks::Govspeak.new([], [])
    render block, {
      schema: schema["properties"]["test_attribute"],
      content: "## bar",
      path: Path.new.push("test_attribute"),
      translated_content:,
    }
    assert_dom "textarea", text: translated_content
  end

  test "it renders any validation errors when they are present" do
    schema = {
      "title" => "Test object",
      "type" => "object",
      "properties" => {
        "test_attribute" => {
          "title" => "Test attribute",
          "type" => "string",
          "format" => "govspeak",
        },
      },
      "validations" => {
        "presence" => {
          "attributes" => %w[test_attribute],
        },
      },
    }

    errors = [mock("object"), mock("object")]
    messages = %w[foo bar]
    errors.each_with_index do |error, index|
      error.expects(:attribute).returns(:test_attribute)
      error.expects(:full_message).returns(messages[index])
    end

    block = ConfigurableContentBlocks::Govspeak.new
    render block, { schema:, content: "## foo", path: Path.new.push("test_attribute"), errors: }
    assert_dom ".govuk-error-message", "Error: #{messages.join}"
  end
end
