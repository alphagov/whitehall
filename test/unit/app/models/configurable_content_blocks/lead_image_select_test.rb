require "test_helper"

class ConfigurableContentBlocks::LeadImageSelectRenderingTest < ActionView::TestCase
  setup do
    @fields = {
      "test_attribute" => {
        "title" => "Test attribute",
        "description" => "A test attribute",
        "block" => "lead_image_select",
      },
    }
    @path = Path.new(%w[block_content test_attribute])
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", {
      "forms" => {
        "documents" => {
          "fields" => @fields,
        },
      },
      "schema" => {
        "attributes" => {
          "test_attribute" => {
            "type" => "integer",
          },
        },
      },
    }))
  end

  test "it renders a select with the selected image filename" do
    images = create_list(:image, 3)
    block_content = { "test_attribute" => images.last.image_data.id.to_s }
    edition = StandardEdition.new(
      configurable_document_type: "test_type",
      block_content:,
      images:,
    )
    block = ConfigurableContentBlocks::LeadImageSelect.new(edition, @fields["test_attribute"], @path)

    render block

    assert_dom "select[name=?]", "edition[block_content][test_attribute]"
    assert_dom "option[selected]", text: images.last.filename
    images.each do |image|
      assert_dom "option", text: image.filename
    end
  end

  test "it renders any validation errors when they are present" do
    messages = %w[foo bar]
    edition = StandardEdition.new
    messages.map { |m| edition.errors.add(:test_attribute, m) }
    block = ConfigurableContentBlocks::LeadImageSelect.new(edition, @fields["test_attribute"], @path)

    render block

    assert_dom ".govuk-error-message", "Error: #{messages.map { |m| "Test attribute #{m}" }.join}"
  end

  test "it renders the default lead image, if no custom lead image has been selected" do
    default_lead_image = build(:featured_image_data)
    organisation = create(:organisation, default_news_image: default_lead_image)
    edition = StandardEdition.new(organisations: [organisation])
    block = ConfigurableContentBlocks::LeadImageSelect.new(edition, @fields["test_attribute"], @path)

    render block

    assert_dom "h2", text: "Default lead image"
    assert "a", text: default_lead_image.url
  end

  test "it renders a placeholder if default lead image is nil" do
    block = ConfigurableContentBlocks::LeadImageSelect.new(StandardEdition.new, @fields["test_attribute"], @path)

    render block

    assert_dom "h2", text: "Default lead image"
    assert_dom "img[src=?]", StandardEdition::DefaultLeadImage::DEFAULT_PLACEHOLDER_IMAGE_URL
  end

  test "it renders a placeholder if default lead image has missing assets" do
    default_lead_image = build(:featured_image_data)
    default_lead_image.assets = []
    default_lead_image.save!

    organisation = create(:organisation, default_news_image: default_lead_image)
    edition = StandardEdition.new(organisations: [organisation])

    block = ConfigurableContentBlocks::LeadImageSelect.new(edition, @fields["test_attribute"], @path)

    render block

    assert_dom "h2", text: "Default lead image"
    assert_dom "img[src=?]", StandardEdition::DefaultLeadImage::DEFAULT_PLACEHOLDER_IMAGE_URL
  end

  test "it does not render the default lead image if a custom lead image has been selected" do
    default_lead_image = build(:featured_image_data)
    images = create_list(:image, 2)
    block_content = { "test_attribute" => images.last.image_data.id.to_s }
    edition = StandardEdition.new(
      configurable_document_type: "test_type",
      block_content:,
      images:,
    )
    block = ConfigurableContentBlocks::LeadImageSelect.new(edition, @fields["test_attribute"], @path)

    render block

    assert "a", text: images.last.url
    assert_dom "h2", text: "Default lead image", count: 0
    assert "a", text: default_lead_image.url, count: 0
  end
end
