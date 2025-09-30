require "test_helper"

class ConfigurableContentBlocks::ImageSelectTest < ActiveSupport::TestCase
  test "it allows the content to be an empty string" do
    validator = ConfigurableContentBlocks::ImageSelect.new.json_schema_validator
    assert validator.call("")
  end

  test "it validates that the content is a string that can be cast to an integer" do
    validator = ConfigurableContentBlocks::ImageSelect.new.json_schema_validator
    assert_not validator.call("abc")
  end

  test "it loads the correct image and presents the image attributes" do
    images = create_list(:image, 3)
    page = StandardEdition.new
    page.images = images
    payload = ConfigurableContentBlocks::ImageSelect.new(page.images).publishing_api_payload(images[1].image_data.id)

    assert_equal({
      url: images[1].url,
      caption: images[1].caption,
    }, payload)
  end

  test "does not have a publishing api payload if no image is selected" do
    payload = ConfigurableContentBlocks::ImageSelect.new.publishing_api_payload("")

    assert_nil payload
  end
end

class ConfigurableContentBlocks::ImageSelectRenderingTest < ActionView::TestCase
  test "it renders a select with the selected image filename" do
    @schema = {
      "type" => "object",
      "properties" => {
        "test_attribute" => {
          "type" => "string",
          "title" => "Test attribute",
          "description" => "A test attribute",
          "format" => "image_select",
        },
      },
    }

    @page = StandardEdition.new
    @page.images = create_list(:image, 3)
    @page.block_content = { "test_attribute" => @page.images.last.image_data.id.to_s }
    @block = ConfigurableContentBlocks::ImageSelect.new(@page.images)

    render @block, {
      schema: @schema["properties"]["test_attribute"],
      content: @page.block_content["test_attribute"],
      path: Path.new.push("test_attribute"),
    }

    assert_dom "select[name=?]", "edition[block_content][test_attribute]"
    assert_dom "option[selected]", text: @page.images.last.filename
    @page.images.each do |image|
      assert_dom "option", text: image.filename
    end
  end

  test "it uses the translated content value when provided" do
    @schema = {
      "type" => "object",
      "properties" => {
        "test_attribute" => {
          "type" => "string",
          "title" => "Test attribute",
          "description" => "A test attribute",
          "format" => "image_select",
        },
      },
    }

    @page = StandardEdition.new
    @page.images = create_list(:image, 3)
    @page.block_content = { "test_attribute" => @page.images.last.image_data.id.to_s }
    @block = ConfigurableContentBlocks::ImageSelect.new(@page.images)

    render @block, {
      schema: @schema["properties"]["test_attribute"],
      content: @page.block_content["test_attribute"],
      translated_content: @page.images.first.image_data.id.to_s,
      path: Path.new.push("test_attribute"),
    }

    assert_dom "select[name=?]", "edition[block_content][test_attribute]"
    assert_dom "option[selected][value=?]", @page.images.first.image_data.id.to_s
  end
end
