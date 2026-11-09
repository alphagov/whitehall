require "test_helper"

class ConfigurableContentBlocks::DefaultStringRenderingTest < ActionView::TestCase
  include ConfigurableContentBlockSharedTests

  setup do
    @field = {
      "block" => "default_string",
      "title" => "Test attribute",
      "description" => "A test attribute",
      "attribute_path" => %w[block_content test_attribute],
      "translatable" => true,
    }
    @path = Path.new(%w[block_content test_attribute])
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", {
      "forms" => {
        "documents" => {
          "fields" => {
            "test_attribute" => @field,
          },
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
    @edition = StandardEdition.new(
      configurable_document_type: "test_type",
      block_content: { "test_attribute" => "foo" },
    )
    @block = ConfigurableContentBlocks::DefaultString.new(@edition, @field, @path)
  end

  test "the form label is equal to the attribute title" do
    render @block
    assert_dom "label", text: @field["title"]
  end

  test "it adds a required message to the label when the attribute is required" do
    @field["required"] = true
    render @block
    assert_dom "label", text: "#{@field['title']} (required)"
  end

  test "it sets the input name correctly" do
    render @block
    assert_dom "input[name=?]", "edition[block_content][test_attribute]"
  end

  test "it sets the input value based on the content" do
    render @block
    assert_dom "input[value=?]", @edition.block_content["test_attribute"]
  end

  test "it sets the hint text based on the description" do
    render @block
    assert_dom ".govuk-hint", text: @field["description"]
  end

  test "it sets the direction on the input to right to left when the current locale is Arabic" do
    with_locale(:ar) do
      render @block
    end
    assert_dom "input[dir=\"rtl\"]"
  end

  test "it renders the primary locale content under the input when the current locale is different from the primary locale" do
    with_locale(:es) do
      render @block
    end

    assert_dom ".govuk-details__text", text: @edition.block_content["test_attribute"]
  end

  test "it renders any validation errors when they are present" do
    messages = %w[foo bar]
    messages.each { |m| @edition.errors.add(:test_attribute, m) }

    render @block
    assert_dom ".govuk-error-message", "Error: #{messages.map { |m| "Test attribute #{m}" }.join}"
  end

  test "it does inherit from parent, if `inherit_from_parent` set and it is an empty field of a new edition" do
    selectors = [
      [
        "[name=\"edition[block_content][test_attribute]\"][value=\"foo\"]",
      ],
    ]

    fill_in_field = proc do |edition|
      edition.block_content = {
        "test_attribute" => "foo",
      }
    end

    it_correctly_inherits_from_parent(ConfigurableContentBlocks::DefaultString, @field, @path, selectors, fill_in_field)
  end

  test "it does not inherit from parent, if `inherit_from_parent` set and it is an empty field of a saved edition" do
    selectors = [
      [
        "[name=\"edition[block_content][test_attribute]\"][value=\"foo\"]",
      ],
    ]

    fill_in_field = proc do |edition|
      edition.block_content = {
        "test_attribute" => "foo",
      }
    end

    it_does_not_inherit_from_parent(ConfigurableContentBlocks::DefaultString, @field, @path, selectors, fill_in_field)
  end
end
