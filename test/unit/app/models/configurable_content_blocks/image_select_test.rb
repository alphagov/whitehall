require "test_helper"

class ConfigurableContentBlocks::ImageSelectTest < ActiveSupport::TestCase
  test "it loads the correct image and presents the image attributes" do
    images = [create(:image), create(:image, caption: "Example caption")]
    payload = ConfigurableContentBlocks::ImageSelect.new(images).publishing_api_payload(images[1].image_data.id)

    assert_equal({
      url: images[1].url,
      caption: images[1].caption,
    }, payload)
  end

  test "it does not send the the caption if nil" do
    image = create(:image, caption: nil)
    payload = ConfigurableContentBlocks::ImageSelect.new([image]).publishing_api_payload(image.image_data.id)

    assert_equal({
      url: image.url,
    }, payload)
  end

  test "does not have a publishing api payload if content is nil" do
    image = create(:image)
    payload = ConfigurableContentBlocks::ImageSelect.new([image]).publishing_api_payload(nil)

    assert_nil payload
  end

  test "does not have a publishing api payload if selected image's assets are not ready" do
    images = create_list(:image, 3)
    images[1].image_data.assets = []
    images[1].image_data.save!

    payload = ConfigurableContentBlocks::ImageSelect.new(images).publishing_api_payload(images[1].image_data.id)

    assert_nil payload
  end
end

class ConfigurableContentBlocks::ImageSelectRenderingTest < ActionView::TestCase
  test "it renders a select with the selected image filename" do
    schema = {
      "type" => "object",
      "properties" => {
        "test_attribute" => {
          "type" => "integer",
          "title" => "Test attribute",
          "description" => "A test attribute",
          "format" => "image_select",
        },
      },
    }

    images = create_list(:image, 3)
    block_content = { "test_attribute" => images.last.image_data.id.to_s }
    block = ConfigurableContentBlocks::ImageSelect.new(images)

    render block, {
      schema: schema["properties"]["test_attribute"],
      content: block_content["test_attribute"],
      path: Path.new.push("test_attribute"),
    }

    assert_dom "select[name=?]", "edition[block_content][test_attribute]"
    assert_dom "option[selected]", text: images.last.filename
    images.each do |image|
      assert_dom "option", text: image.filename
    end
  end

  test "it uses the translated content value when provided" do
    schema = {
      "type" => "object",
      "properties" => {
        "test_attribute" => {
          "type" => "integer",
          "title" => "Test attribute",
          "description" => "A test attribute",
          "format" => "image_select",
        },
      },
    }

    images = create_list(:image, 3)
    block_content = { "test_attribute" => images.last.image_data.id.to_s }
    block = ConfigurableContentBlocks::ImageSelect.new(images)

    render block, {
      schema: schema["properties"]["test_attribute"],
      content: block_content["test_attribute"],
      translated_content: images.first.image_data.id,
      path: Path.new.push("test_attribute"),
    }

    assert_dom "select[name=?]", "edition[block_content][test_attribute]"
    assert_dom "option[selected][value=?]", images.first.image_data.id
  end

  test "it renders any validation errors when they are present" do
    schema = {
      "title" => "Test object",
      "type" => "object",
      "properties" => {
        "test_attribute" => {
          "type" => "integer",
          "title" => "Test attribute",
          "description" => "A test attribute",
          "format" => "image_select",
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
    block = ConfigurableContentBlocks::ImageSelect.new([create(:image)])

    render block, {
      schema:,
      content: nil,
      path: Path.new.push("test_attribute"),
      errors:,
    }
    assert_dom ".govuk-error-message", "Error: #{messages.join}"
  end
end

class ConfigurableContentBlocks::ImageSelectRenderingTestWithForms < ActionView::TestCase
  setup do
    @schema = {
      "test_attribute" => {
        "title" => "Test attribute",
        "description" => "A test attribute",
        "block" => "image_select",
      },
    }
    @path = Path.new(%w[test_attribute])
  end

  test "it renders a select with the selected image filename" do
    images = create_list(:image, 3)
    block_content = { "test_attribute" => images.last.image_data.id.to_s }
    block = ConfigurableContentBlocks::ImageSelect.new(images)

    render block, {
      schema: @schema["test_attribute"],
      content: block_content["test_attribute"],
      path: @path,
    }

    assert_dom "select[name=?]", "edition[block_content][test_attribute]"
    assert_dom "option[selected]", text: images.last.filename
    images.each do |image|
      assert_dom "option", text: image.filename
    end
  end

  test "it uses the translated content value when provided" do
    images = create_list(:image, 3)
    block_content = { "test_attribute" => images.last.image_data.id.to_s }
    block = ConfigurableContentBlocks::ImageSelect.new(images)

    render block, {
      schema: @schema["test_attribute"],
      content: block_content["test_attribute"],
      translated_content: images.first.image_data.id,
      path: @path,
    }

    assert_dom "select[name=?]", "edition[block_content][test_attribute]"
    assert_dom "option[selected][value=?]", images.first.image_data.id
  end

  test "it renders any validation errors when they are present" do
    errors = [mock("object"), mock("object")]
    messages = %w[foo bar]
    errors.each_with_index do |error, index|
      error.expects(:attribute).returns(:test_attribute)
      error.expects(:full_message).returns(messages[index])
    end
    block = ConfigurableContentBlocks::ImageSelect.new([create(:image)])
    render block, {
      schema: @schema["test_attribute"],
      content: nil,
      path: @path,
      errors:,
    }
    assert_dom ".govuk-error-message", "Error: #{messages.join}"
  end
end
