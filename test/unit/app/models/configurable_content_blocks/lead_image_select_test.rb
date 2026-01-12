require "test_helper"

class ConfigurableContentBlocks::LeadImageSelectRenderingTest < ActionView::TestCase
  setup do
    @schema = {
      "test_attribute" => {
        "title" => "Test attribute",
        "description" => "A test attribute",
        "block" => "lead_image_select",
      },
    }
    @path = Path.new(%w[test_attribute])
  end

  test "it renders a select with the selected image filename" do
    images = create_list(:image, 3)
    block_content = { "test_attribute" => images.last.image_data.id.to_s }
    block = ConfigurableContentBlocks::LeadImageSelect.new(images)

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
    block = ConfigurableContentBlocks::LeadImageSelect.new(images)

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
    block = ConfigurableContentBlocks::LeadImageSelect.new([create(:image)])

    render block, {
      schema: @schema["test_attribute"],
      content: nil,
      path: @path,
      errors:,
    }

    assert_dom ".govuk-error-message", "Error: #{messages.join}"
  end

  test "it renders the default lead image, if no custom lead image has been selected" do
    default_lead_image = build(:featured_image_data)
    block = ConfigurableContentBlocks::LeadImageSelect.new([], default_lead_image:)

    render block, {
      schema: @schema["test_attribute"],
      content: nil,
      path: @path,
    }

    assert_dom "h2", text: "Default lead image"
    assert "a", text: default_lead_image.url
  end

  test "it renders a placeholder if default lead image is nil" do
    placeholder_image_url = "https://assets.publishing.service.gov.uk/media/_ID_/placeholder.jpg"
    block = ConfigurableContentBlocks::LeadImageSelect.new([], default_lead_image: nil, placeholder_image_url:)

    render block, {
      schema: @schema["test_attribute"],
      content: nil,
      path: @path,
    }

    assert_dom "h2", text: "Default lead image"
    assert_dom "img[src=?]", placeholder_image_url
  end

  test "it renders a placeholder if default lead image has missing assets" do
    default_lead_image = build(:featured_image_data)
    default_lead_image.assets = []
    default_lead_image.save!
    placeholder_image_url = "https://assets.publishing.service.gov.uk/media/_ID_/placeholder.jpg"
    block = ConfigurableContentBlocks::LeadImageSelect.new([], default_lead_image:, placeholder_image_url:)

    render block, {
      schema: @schema["test_attribute"],
      content: nil,
      path: @path,
    }

    assert_dom "h2", text: "Default lead image"
    assert_dom "img[src=?]", placeholder_image_url
  end

  test "it does not render the default lead image if a custom lead image has been selected" do
    default_lead_image = build(:featured_image_data)
    images = create_list(:image, 2)
    block_content = { "test_attribute" => images.last.image_data.id.to_s }
    block = ConfigurableContentBlocks::LeadImageSelect.new(images, default_lead_image:)

    render block, {
      schema: @schema["test_attribute"],
      content: block_content["test_attribute"],
      path: @path,
    }

    assert "a", text: images.last.url
    assert_dom "h2", text: "Default lead image", count: 0
    assert "a", text: default_lead_image.url, count: 0
  end
end
