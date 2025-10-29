require "test_helper"

class ConfigurableContentBlocks::LeadImageSelectTest < ActiveSupport::TestCase
  test "it sends the custom lead image payload to publishing-api" do
    images = [create(:image), create(:image, caption: "Example caption")]
    payload = ConfigurableContentBlocks::LeadImageSelect.new(images).publishing_api_payload(images[1].image_data.id)

    assert_equal({
      high_resolution_url: images[1].image_data.url(:s960),
      url: images[1].image_data&.url(:s300),
      caption: images[1].caption,
    }, payload)
  end

  test "it does not send the the caption if nil" do
    image = create(:image, caption: nil)
    payload = ConfigurableContentBlocks::LeadImageSelect.new([image]).publishing_api_payload(image.image_data.id)

    assert_equal({
      high_resolution_url: image.image_data.url(:s960),
      url: image.image_data&.url(:s300),
    }, payload)
  end

  test "it sends the default lead image payload if custom lead is missing" do
    default_lead_image = build(:featured_image_data)
    payload = ConfigurableContentBlocks::LeadImageSelect.new([], default_lead_image:).publishing_api_payload("")

    assert_equal({
      high_resolution_url: default_lead_image.url(:s960),
      url: default_lead_image.url(:s300),
    }, payload)
  end

  test "it sends the placeholder image url if selected image's assets are missing" do
    images = create_list(:image, 3)
    images[1].image_data.assets = []
    images[1].image_data.save!

    payload = ConfigurableContentBlocks::LeadImageSelect.new(images).publishing_api_payload(images[1].image_data.id)
    assert_equal({
      high_resolution_url: "https://assets.publishing.service.gov.uk/media/5e59279b86650c53b2cefbfe/placeholder.jpg",
      url: "https://assets.publishing.service.gov.uk/media/5e59279b86650c53b2cefbfe/placeholder.jpg",
    }, payload)
  end

  test "it sends the placeholder image url if there is no custom image and default lead image's assets are missing" do
    default_lead_image = build(:featured_image_data)
    default_lead_image.assets = []
    default_lead_image.save!

    payload = ConfigurableContentBlocks::LeadImageSelect.new([], default_lead_image:).publishing_api_payload(nil)
    assert_equal({
      high_resolution_url: "https://assets.publishing.service.gov.uk/media/5e59279b86650c53b2cefbfe/placeholder.jpg",
      url: "https://assets.publishing.service.gov.uk/media/5e59279b86650c53b2cefbfe/placeholder.jpg",
    }, payload)
  end

  test "it sends the placeholder image url if custom lead and organisation default images are missing" do
    payload = ConfigurableContentBlocks::LeadImageSelect.new([]).publishing_api_payload("")

    assert_equal({
      high_resolution_url: "https://assets.publishing.service.gov.uk/media/5e59279b86650c53b2cefbfe/placeholder.jpg",
      url: "https://assets.publishing.service.gov.uk/media/5e59279b86650c53b2cefbfe/placeholder.jpg",
    }, payload)
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
    images = create_list(:image, 3)
    block_content = { "test_attribute" => images.last.image_data.id.to_s }
    block = ConfigurableContentBlocks::LeadImageSelect.new(images)

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
          "format" => "lead_image_select",
        },
      },
    }
    images = create_list(:image, 3)
    block_content = { "test_attribute" => images.last.image_data.id.to_s }
    block = ConfigurableContentBlocks::LeadImageSelect.new(images)

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
          "format" => "lead_image_select",
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
    block = ConfigurableContentBlocks::LeadImageSelect.new([create(:image)])

    render block, {
      schema:,
      content: nil,
      path: Path.new.push("test_attribute"),
      errors:,
    }

    assert_dom ".govuk-error-message", "Error: #{messages.join}"
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
    default_lead_image = build(:featured_image_data)
    block = ConfigurableContentBlocks::LeadImageSelect.new([], default_lead_image:)

    render block, {
      schema: schema["properties"]["test_attribute"],
      content: nil,
      path: Path.new.push("test_attribute"),
    }

    assert_dom "h2", text: "Default lead image"
    assert "a", text: default_lead_image.url
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
    block = ConfigurableContentBlocks::LeadImageSelect.new([], default_lead_image: nil)

    render block, {
      schema: schema["properties"]["test_attribute"],
      content: nil,
      path: Path.new.push("test_attribute"),
    }

    assert_dom "h2", text: "Default lead image"
    assert_dom "img[src=?]", "https://assets.publishing.service.gov.uk/media/5e59279b86650c53b2cefbfe/placeholder.jpg"
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
    default_lead_image = build(:featured_image_data)
    images = create_list(:image, 2)
    block_content = { "test_attribute" => images.last.image_data.id.to_s }
    block = ConfigurableContentBlocks::LeadImageSelect.new(images, default_lead_image:)

    render block, {
      schema: schema["properties"]["test_attribute"],
      content: block_content["test_attribute"],
      path: Path.new.push("test_attribute"),
    }

    assert "a", text: images.last.url
    assert_dom "h2", text: "Default lead image", count: 0
    assert "a", text: default_lead_image.url, count: 0
  end
end
