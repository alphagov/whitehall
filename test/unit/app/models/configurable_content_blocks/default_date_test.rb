require "test_helper"

class ConfigurableContentBlocks::DefaultDateRenderingTest < ActionView::TestCase
  setup do
    @schema = {
      "test_attribute" => {
        "block" => "default_date",
        "title" => "Test attribute",
        "description" => "A test attribute",
        "attribute_path" => %w[block_content test_attribute],
      },
    }
    @date = Time.zone.now
    @translated_date = Time.zone.tomorrow
    @block_content = { "test_attribute" => @date }
    @translated_block_content = { "test_attribute" => @translated_date }
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", {
      "forms" => {
        "documents" => {
          "fields" => @schema,
        },
      },
      "schema" => {
        "attributes" => {
          "test_attribute" => {
            "type" => "date",
          },
        },
      },
    }))
    @edition = StandardEdition.new(
      configurable_document_type: "test_type",
      block_content: @block_content,
    )
    @block = ConfigurableContentBlocks::DefaultDate.new(@edition, @schema["test_attribute"], Path.new(%w[block_content test_attribute]))
  end

  test "it renders a default date field" do
    render @block
    assert_dom "legend", text: @schema["test_attribute"]["title"]
  end

  test "it renders hint text" do
    render @block
    assert_dom "div.gem-c-hint.govuk-hint", text: "For example, 01 08 2015"
  end

  test "it renders day, month and year" do
    render @block

    assert_dom "input[name=\"edition[block_content][test_attribute][3]\"][value=\"#{@date.day}\"]"
    assert_dom "input[name=\"edition[block_content][test_attribute][2]\"][value=\"#{@date.month}\"]"
    assert_dom "input[name=\"edition[block_content][test_attribute][1]\"][value=\"#{@date.year}\"]"
  end

  test "it renders errors" do
    messages = %w[foo bar]
    @edition.errors.add(:test_attribute, messages.first)
    @edition.errors.add(:test_attribute, messages.last)

    render @block
    assert_dom ".govuk-error-message", "Error: #{messages.map { |m| "Test attribute #{m}" }.join}"
    @edition.errors.clear
  end

  test "it maintains invalid content values if there are errors" do
    messages = %w[foo bar]
    @edition.errors.add(:test_attribute, messages.first)
    @edition.errors.add(:test_attribute, messages.last)

    params.merge!({ "edition": { "block_content": { "test_attribute": { "1": "2024", "2": "10", "3": "10" } } } })
    render @block
    assert_dom "input[name=\"edition[block_content][test_attribute][3]\"][value=\"#{params['edition']['block_content']['test_attribute']['3']}\"]"
    assert_dom "input[name=\"edition[block_content][test_attribute][2]\"][value=\"#{params['edition']['block_content']['test_attribute']['2']}\"]"
    assert_dom "input[name=\"edition[block_content][test_attribute][1]\"][value=\"#{params['edition']['block_content']['test_attribute']['1']}\"]"
    @edition.errors.clear
  end
end
