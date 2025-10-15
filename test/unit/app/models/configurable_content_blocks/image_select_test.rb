require "test_helper"

class ConfigurableContentBlocks::ImageSelectTest < ActiveSupport::TestCase
  test "it loads the correct image and presents the image attributes" do
    images = create_list(:image, 3)
    payload = ConfigurableContentBlocks::ImageSelect.new(images).publishing_api_payload(images[1].image_data.id)

    assert_equal({
      url: images[1].url,
      caption: images[1].caption,
    }, payload)
  end

  test "does not have a publishing api payload if selected image's assets are not ready" do
    images = create_list(:image, 3)
    page = StandardEdition.new
    page.images = images
    images[1].image_data.assets = []
    images[1].image_data.save!

    payload = ConfigurableContentBlocks::ImageSelect.new(page.images).publishing_api_payload(images[1].image_data.id)

    assert_nil payload
  end
end

class ConfigurableContentBlocks::ImageSelectRenderingTest < ActionView::TestCase
  test "it renders a select with the selected image filename" do
    schema = {
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
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", { schema: }))

    page = StandardEdition.new
    page.configurable_document_type = "test_type"
    page.images = create_list(:image, 3)
    page.block_content = { "test_attribute" => page.images.last.image_data.id.to_s }
    block = ConfigurableContentBlocks::ImageSelect.new(page.images)

    render block, {
      schema: schema["properties"]["test_attribute"],
      content: page.block_content["test_attribute"],
      path: Path.new.push("test_attribute"),
    }

    assert_dom "select[name=?]", "edition[block_content][test_attribute]"
    assert_dom "option[selected]", text: page.images.last.filename
    page.images.each do |image|
      assert_dom "option", text: image.filename
    end
  end

  test "it uses the translated content value when provided" do
    schema = {
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
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", { schema: }))

    page = StandardEdition.new
    page.configurable_document_type = "test_type"
    page.images = create_list(:image, 3)
    page.block_content = { "test_attribute" => page.images.last.image_data.id.to_s }
    block = ConfigurableContentBlocks::ImageSelect.new(page.images)

    render block, {
      schema: schema["properties"]["test_attribute"],
      content: page.block_content["test_attribute"],
      translated_content: page.images.first.image_data.id,
      path: Path.new.push("test_attribute"),
    }

    assert_dom "select[name=?]", "edition[block_content][test_attribute]"
    assert_dom "option[selected][value=?]", page.images.first.image_data.id
  end

  test "it renders any validation errors when they are present" do
    schema = {
      "type" => "object",
      "properties" => {
        "test_attribute" => {
          "type" => "string",
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
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", { "schema" => schema }))

    page = StandardEdition.new
    page.configurable_document_type = "test_type"
    page.images = create_list(:image, 3)
    page.block_content = { "test_attribute" => nil }
    page.validate
    block = ConfigurableContentBlocks::ImageSelect.new(page.images)

    render block, {
      schema: schema["properties"]["test_attribute"],
      content: page.block_content["test_attribute"],
      path: Path.new.push("test_attribute"),
      errors: page.errors,
    }
    assert_dom ".govuk-error-message", "Error: #{page.errors.where(:test_attribute).map(&:full_message).join}"
  end
end
