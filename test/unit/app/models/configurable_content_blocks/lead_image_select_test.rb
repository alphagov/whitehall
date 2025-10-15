require "test_helper"

class ConfigurableContentBlocks::LeadImageSelectTest < ActiveSupport::TestCase
  test "it loads the correct image and presents the image attributes" do
    images = create_list(:image, 3)
    payload = ConfigurableContentBlocks::LeadImageSelect.new(images).publishing_api_payload(images[1].image_data.id)

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

    payload = ConfigurableContentBlocks::LeadImageSelect.new(page.images).publishing_api_payload(images[1].image_data.id)

    assert_nil payload
  end
end

class ConfigurableContentBlocks::LeadImageSelectRenderingTest < ActionView::TestCase
  test "it renders a select with the selected image filename" do
    schema = {
      "type" => "object",
      "properties" => {
        "test_attribute" => {
          "type" => "integer",
          "title" => "Test attribute",
          "description" => "A test attribute",
          "format" => "lead_image_select",
        },
      },
    }
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", { schema: }))

    page = StandardEdition.new
    page.configurable_document_type = "test_type"
    page.images = create_list(:image, 3)
    page.block_content = { "test_attribute" => page.images.last.image_data.id.to_s }
    block = ConfigurableContentBlocks::LeadImageSelect.new(page.images)

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
          "type" => "integer",
          "title" => "Test attribute",
          "description" => "A test attribute",
          "format" => "lead_image_select",
        },
      },
    }
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", { schema: }))

    page = StandardEdition.new
    page.configurable_document_type = "test_type"
    page.images = create_list(:image, 3)
    page.block_content = { "test_attribute" => page.images.last.image_data.id.to_s }
    block = ConfigurableContentBlocks::LeadImageSelect.new(page.images)

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
          "type" => "integer",
          "title" => "Test attribute",
          "description" => "A test attribute",
          "format" => "lead_image_select",
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
    block = ConfigurableContentBlocks::LeadImageSelect.new(page.images)

    render block, {
      schema: schema["properties"]["test_attribute"],
      content: page.block_content["test_attribute"],
      path: Path.new.push("test_attribute"),
      errors: page.errors,
    }
    assert_dom ".govuk-error-message", "Error: #{page.errors.where(:test_attribute).map(&:full_message).join}"
  end

  test "it renders the default lead image, if no custom lead image has been selected" do
    schema = {
      "type" => "object",
      "properties" => {
        "test_attribute" => {
          "type" => "integer",
          "title" => "Test attribute",
          "description" => "A test attribute",
          "format" => "lead_image_select",
        },
      },
    }
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", { schema: }))
    default_image = build(:organisation, :with_default_news_image).default_news_image
    block = ConfigurableContentBlocks::LeadImageSelect.new([], default_lead_image: default_image)

    render block, {
      schema: schema["properties"]["test_attribute"],
      content: nil,
      path: Path.new.push("test_attribute"),
    }

    assert_dom "h2", text: "Default lead image"
    assert "a", text: default_image.url
  end

  test "it renders a placeholder if default lead image is nil" do
    schema = {
      "type" => "object",
      "properties" => {
        "test_attribute" => {
          "type" => "integer",
          "title" => "Test attribute",
          "description" => "A test attribute",
          "format" => "lead_image_select",
        },
      },
    }
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", { schema: }))
    block = ConfigurableContentBlocks::LeadImageSelect.new([], default_lead_image: nil)

    render block, {
      schema: schema["properties"]["test_attribute"],
      content: nil,
      path: Path.new.push("test_attribute"),
    }

    assert_dom "h2", text: "Default lead image"
    assert_dom "img[src=?]", ActionController::Base.helpers.image_url("placeholder.jpg", host: Whitehall.public_root)
  end

  test "it does not render the default lead image if a custom lead image has been selected" do
    schema = {
      "type" => "object",
      "properties" => {
        "test_attribute" => {
          "type" => "integer",
          "title" => "Test attribute",
          "description" => "A test attribute",
          "format" => "lead_image_select",
        },
      },
    }
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", { schema: }))
    page = StandardEdition.new
    page.configurable_document_type = "test_type"
    default_image = build(:organisation, :with_default_news_image).default_news_image
    page.images = create_list(:image, 2)
    page.block_content = { "test_attribute" => page.images.last.image_data.id.to_s }
    block = ConfigurableContentBlocks::LeadImageSelect.new(page.images, default_lead_image: default_image)

    render block, {
      schema: schema["properties"]["test_attribute"],
      content: page.block_content["test_attribute"],
      path: Path.new.push("test_attribute"),
    }

    assert "a", text: page.images.last.url
    assert_dom "h2", text: "Default lead image", count: 0
    assert "a", text: default_image.url, count: 0
  end
end
