require "test_helper"

class ConfigurableContentBlocks::DefaultDateTest < ActiveSupport::TestCase
  test "it presents the content" do
    payload = ConfigurableContentBlocks::DefaultDate.new.publishing_api_payload(Time.zone.now)
    assert_equal(Time.zone.now.rfc3339, payload)
  end
end

class ConfigurableContentBlocks::DefaultDateRenderingTest < ActionView::TestCase
  setup do
    @schema = {
      "type" => "object",
      "properties" => {
        "test_attribute" => {
          "type" => "date",
          "title" => "Test attribute",
          "description" => "A test attribute",
        },
      },
    }
    @date = Time.zone.now
    @block_content = { "test_attribute" => @date }
    @block = ConfigurableContentBlocks::DefaultDate.new
  end

  test "it renders a default date field" do
    render @block, {
      schema: @schema["properties"]["test_attribute"],
      content: @block_content["test_attribute"],
      path: Path.new.push("test_attribute"),
    }
    assert_dom "legend", text: @schema["properties"]["test_attribute"]["title"]
  end

  test "it renders hint text" do
    render @block, {
      schema: @schema["properties"]["test_attribute"],
      content: @block_content["test_attribute"],
      path: Path.new.push("test_attribute"),
    }
    assert_dom "div.gem-c-hint.govuk-hint", text: "For example, 01 08 2015"
  end

  test "it renders day, month and year" do
    render @block, {
      schema: @schema["properties"]["test_attribute"],
      content: @block_content["test_attribute"],
      path: Path.new.push("test_attribute"),
    }

    assert_dom "input[name=\"edition[block_content][test_attribute(3i)]\"][value=\"#{@date.day}\"]"
    assert_dom "input[name=\"edition[block_content][test_attribute(2i)]\"][value=\"#{@date.month}\"]"
    assert_dom "input[name=\"edition[block_content][test_attribute(1i)]\"][value=\"#{@date.year}\"]"
  end

  test "it renders errors" do
    errors = [mock("object"), mock("object")]
    messages = %w[foo bar]
    errors.each_with_index do |error, index|
      error.expects(:attribute).returns(:test_attribute)
      error.expects(:full_message).returns(messages[index])
    end

    render @block, {
      schema: @schema["properties"]["test_attribute"],
      content: @block_content["test_attribute"],
      path: Path.new.push("test_attribute"),
      errors:,
    }
    assert_dom ".govuk-error-message", "Error: #{messages.join}"
  end
end
