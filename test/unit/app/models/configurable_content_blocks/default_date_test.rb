require "test_helper"

class ConfigurableContentBlocks::DefaultDateRenderingTest < ActionView::TestCase
  setup do
    @schema = {
      "test_attribute" => {
        "block" => "default_date",
        "title" => "Test attribute",
        "description" => "A test attribute",
      },
    }
    @date = Time.zone.now
    @translated_date = Time.zone.tomorrow
    @block_content = { "test_attribute" => @date }
    @translated_block_content = { "test_attribute" => @translated_date }
    @block = ConfigurableContentBlocks::DefaultDate.new
    @path = Path.new(%w[test_attribute])
  end

  test "it renders a default date field" do
    render @block, {
      schema: @schema["test_attribute"],
      content: @block_content["test_attribute"],
      path: @path,
      translated_content: nil,
    }
    assert_dom "legend", text: @schema["test_attribute"]["title"]
  end

  test "it renders hint text" do
    render @block, {
      schema: @schema["test_attribute"],
      content: @block_content["test_attribute"],
      path: @path,
      translated_content: nil,
    }
    assert_dom "div.gem-c-hint.govuk-hint", text: "For example, 01 08 2015"
  end

  test "it renders day, month and year" do
    render @block, {
      schema: @schema["test_attribute"],
      content: @block_content["test_attribute"],
      path: @path,
      translated_content: nil,
    }

    assert_dom "input[name=\"edition[block_content][test_attribute][3]\"][value=\"#{@date.day}\"]"
    assert_dom "input[name=\"edition[block_content][test_attribute][2]\"][value=\"#{@date.month}\"]"
    assert_dom "input[name=\"edition[block_content][test_attribute][1]\"][value=\"#{@date.year}\"]"
  end

  test "it renders day, month and year for translated content" do
    render @block, {
      schema: @schema["test_attribute"],
      content: @block_content["test_attribute"],
      path: @path,
      translated_content: @translated_block_content["test_attribute"],
    }

    assert_dom "input[name=\"edition[block_content][test_attribute][3]\"][value=\"#{@translated_date.day}\"]"
    assert_dom "input[name=\"edition[block_content][test_attribute][2]\"][value=\"#{@translated_date.month}\"]"
    assert_dom "input[name=\"edition[block_content][test_attribute][1]\"][value=\"#{@translated_date.year}\"]"
  end

  test "it renders errors" do
    errors = [mock("object"), mock("object")]
    messages = %w[foo bar]
    errors.each_with_index do |error, index|
      error.expects(:attribute).returns(:test_attribute)
      error.expects(:full_message).returns(messages[index])
    end

    render @block, {
      schema: @schema["test_attribute"],
      content: @block_content["test_attribute"],
      path: @path,
      translated_content: nil,
      errors:,
    }
    assert_dom ".govuk-error-message", "Error: #{messages.join}"
  end

  test "it maintains invalid content values if there are errors" do
    errors = [mock("object"), mock("object")]
    messages = %w[foo bar]
    errors.each_with_index do |error, index|
      error.expects(:attribute).returns(:test_attribute)
      error.expects(:full_message).returns(messages[index])
    end

    params.merge!({ "edition": { "block_content": { "test_attribute": { "1": "2024", "2": "10", "3": "10" } } } })
    render @block, {
      schema: @schema["test_attribute"],
      content: @block_content["test_attribute"],
      path: @path,
      translated_content: nil,
      errors:,
    }
    assert_dom "input[name=\"edition[block_content][test_attribute][3]\"][value=\"#{params['edition']['block_content']['test_attribute']['3']}\"]"
    assert_dom "input[name=\"edition[block_content][test_attribute][2]\"][value=\"#{params['edition']['block_content']['test_attribute']['2']}\"]"
    assert_dom "input[name=\"edition[block_content][test_attribute][1]\"][value=\"#{params['edition']['block_content']['test_attribute']['1']}\"]"
  end
end
