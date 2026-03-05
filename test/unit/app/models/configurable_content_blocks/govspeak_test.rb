require "test_helper"

class ConfigurableContentBlocks::GovspeakRenderingTest < ActionView::TestCase
  include ConfigurableContentBlockSharedTests

  setup do
    @field = {
      "block" => "govspeak",
      "title" => "Test attribute",
      "description" => "A test attribute",
      "attribute_path" => %w[block_content test_attribute],
      "translatable" => true,
    }
    @path = Path.new(%w[block_content test_attribute])
    @edition = StandardEdition.new(configurable_document_type: "test_type")
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", {
      "forms" => {
        "documents" => {
          "fields" => { "test_attribute" => @field },
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
    @block = ConfigurableContentBlocks::Govspeak.new(@edition, @field, @path)
  end

  test "it renders a govspeak editor with attachments and images for embedding" do
    file_attachment = create(:file_attachment)
    image = create(:image)
    govspeak_content = "## foo\n[Attachment: #{file_attachment.filename}]"
    @edition.block_content = { "test_attribute" => govspeak_content }
    @edition.images = [image]
    @edition.attachments = [file_attachment]

    render @block

    assert_dom ".app-c-govspeak-editor[data-attachment-ids=\"[#{file_attachment.id}]\"][data-image-ids=\"[#{image.id}]\"]"
  end

  test "it sets the direction on the textarea to right to left when the locale is set to Arabic" do
    with_locale(:ar) do
      render @block
    end
    assert_dom ".app-c-govspeak-editor textarea[dir=\"rtl\"]"
  end

  test "it renders the primary locale content under the textarea when the translated content is provided" do
    govspeak_content = "## foo"
    @edition.block_content = { "test_attribute" => govspeak_content }
    with_locale(:es) do
      render @block
    end
    assert_dom ".govuk-details__text", text: govspeak_content
  end

  test "it renders any validation errors when they are present" do
    messages = %w[foo bar]
    messages.each { |m| @edition.errors.add(:test_attribute, m) }
    render @block
    assert_dom ".govuk-error-message", "Error: #{messages.map { |m| "Test attribute #{m}" }.join}"
  end
end
