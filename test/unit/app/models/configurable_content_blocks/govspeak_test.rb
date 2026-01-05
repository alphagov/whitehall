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
    assert_not doc.css("img[src=\"#{image.embed_url}\"]").empty?
    assert_match(/A paragraph followed by an image/m, doc.text)
  end

  test "does not have a publishing api payload if content is nil" do
    payload = ConfigurableContentBlocks::Govspeak.new.publishing_api_payload(nil)

    assert_nil payload
  end
end

class ConfigurableContentBlocks::GovspeakRenderingTest < ActionView::TestCase
  setup do
    @schema = {
      "test_attribute" => {
        "block" => "govspeak",
        "title" => "Test attribute",
        "description" => "A test attribute",
      },
    }
    @path = Path.new(%w[test_attribute])
  end

  test "it renders a govspeak editor with attachments and images for embedding" do
    file_attachment = create(:file_attachment)
    image = create(:image)
    govspeak_content = "## foo\n[Attachment: #{file_attachment.filename}]"
    block = ConfigurableContentBlocks::Govspeak.new([image], [file_attachment])

    render block, {
      schema: @schema["test_attribute"],
      content: govspeak_content,
      path: @path,
    }

    assert_dom ".app-c-govspeak-editor[data-attachment-ids=\"[#{file_attachment.id}]\"][data-image-ids=\"[#{image.id}]\"]"
  end

  test "it sets the direction on the textarea to right to left when the rtl option returns true" do
    govspeak_content = "## foo"
    block = ConfigurableContentBlocks::Govspeak.new([], [])
    render block, {
      schema: @schema["test_attribute"],
      content: govspeak_content,
      path: @path,
      right_to_left: true,
    }
    assert_dom ".app-c-govspeak-editor textarea[dir=\"rtl\"]"
  end

  test "it renders the primary locale content under the textarea when the translated content is provided" do
    govspeak_content = "## foo"
    block = ConfigurableContentBlocks::Govspeak.new([], [])
    render block, {
      schema: @schema["test_attribute"],
      content: govspeak_content,
      path: @path,
      translated_content: "## bar",
    }
    assert_dom ".govuk-details__text", text: govspeak_content
  end

  test "it sets the value of the textarea to the translated content when the translated content is provided" do
    translated_content = "## foo"
    block = ConfigurableContentBlocks::Govspeak.new([], [])
    render block, {
      schema: @schema["test_attribute"],
      content: "## bar",
      path: @path,
      translated_content:,
    }
    assert_dom "textarea", text: translated_content
  end

  test "it renders any validation errors when they are present" do
    errors = [mock("object"), mock("object")]
    messages = %w[foo bar]
    errors.each_with_index do |error, index|
      error.expects(:attribute).returns(:test_attribute)
      error.expects(:full_message).returns(messages[index])
    end

    block = ConfigurableContentBlocks::Govspeak.new
    render block, { schema: @schema["test_attribute"], content: "## foo", path: @path, errors: }
    assert_dom ".govuk-error-message", "Error: #{messages.join}"
  end
end
