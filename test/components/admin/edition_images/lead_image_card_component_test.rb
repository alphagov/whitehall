# frozen_string_literal: true

require "test_helper"

class Admin::EditionImages::LeadImageCardComponentTest < ViewComponent::TestCase
  include Rails.application.routes.url_helpers

  test "summary card actions contains Edit and Delete options if image present" do
    image_data = create(:image_data, image_kind: "default")
    image = build_stubbed(:image, usage: "lead", image_data:)
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", lead_image_usage_test_type))
    edition = build_stubbed(:draft_standard_edition, images: [image])
    lead_usage = edition.permitted_image_usages.find { |usage| usage.key == "lead" }

    render_inline(Admin::EditionImages::LeadImageCardComponent.new(edition:, image:, image_usage: lead_usage))

    assert_selector ".govuk-link[href='#{edit_admin_edition_image_path(edition, image)}']", text: "Edit"
    assert_selector ".govuk-link[href='#{confirm_destroy_admin_edition_image_path(edition, image)}']", text: "Delete"
  end

  test "summary card actions contains Replace and Delete options if image and fallback not present" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", lead_image_usage_test_type))
    edition = build_stubbed(:draft_standard_edition)
    lead_usage = edition.permitted_image_usages.find { |usage| usage.key == "lead" }

    render_inline(Admin::EditionImages::LeadImageCardComponent.new(edition:, image: nil, image_usage: lead_usage))

    assert_selector ".govuk-link[href='#{new_admin_edition_image_path(edition_id: edition.id, usage: lead_usage.key)}']", text: "Replace"
    assert_selector ".govuk-link[href='#{confirm_toggle_default_lead_image_behaviour_admin_edition_images_path(edition)}']", text: "Delete"
  end

  test "summary card actions contains 'Add image' and 'Use default image' options if no custom or default image is present" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", lead_image_usage_test_type))
    edition = build_stubbed(:standard_edition, image_display_option: "no_image")
    lead_usage = edition.permitted_image_usages.find { |usage| usage.key == "lead" }

    render_inline(Admin::EditionImages::LeadImageCardComponent.new(edition:, image: nil, image_usage: lead_usage))

    assert_selector ".govuk-link[href='#{new_admin_edition_image_path(edition_id: edition.id, usage: lead_usage.key)}']", text: "Add image"
    assert_selector ".govuk-link[href='#{confirm_toggle_default_lead_image_behaviour_admin_edition_images_path(edition)}']", text: "Use default image"
  end

  test "there are no summary card actions if the edition isn't editable" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", lead_image_usage_test_type))
    edition = build_stubbed(:published_standard_edition)
    lead_usage = edition.permitted_image_usages.find { |usage| usage.key == "lead" }

    render_inline(Admin::EditionImages::LeadImageCardComponent.new(edition:, image: nil, image_usage: lead_usage))

    assert_selector ".govuk-link", count: 0
  end

  test "renders lead image guidance" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", lead_image_usage_test_type))
    edition = build_stubbed(:standard_edition)
    lead_usage = edition.permitted_image_usages.find { |usage| usage.key == "lead" }

    render_inline(Admin::EditionImages::LeadImageCardComponent.new(edition:, image: nil, image_usage: lead_usage))

    assert_selector ".govuk-details__summary-text", text: "Using a lead image"
  end

  test "renders the thumbnail for a 'lead' usage image" do
    image_data = create(:image_data, image_kind: "default")
    image = build_stubbed(:image, usage: "lead", image_data:)
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", lead_image_usage_test_type))
    edition = build_stubbed(:standard_edition, images: [image])
    lead_usage = edition.permitted_image_usages.find { |usage| usage.key == "lead" }

    render_inline(Admin::EditionImages::LeadImageCardComponent.new(edition:, image:, image_usage: lead_usage))

    assert_selector "img[src='#{image.thumbnail}']"
  end

  test "renders the default lead image thumbnail when no custom lead image is provided" do
    default_lead_image = build(:featured_image_data)
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", lead_image_usage_test_type))
    edition = create(:standard_edition, images: [], organisations: [create(:organisation, default_news_image: default_lead_image)])
    lead_usage = edition.permitted_image_usages.find { |usage| usage.key == "lead" }

    render_inline(Admin::EditionImages::LeadImageCardComponent.new(edition:, image: nil, image_usage: lead_usage))

    assert_selector "img[src='#{default_lead_image.url(:s300)}']"
  end

  test "renders the 'PROCESSING' tag image when lead image is selected but has missing assets" do
    lead_image = create(:image, usage: "lead", image_data: build(:image_data_with_no_assets))
    placeholder_image_url = "https://assets.publishing.service.gov.uk/media/_ID_/placeholder.jpg"
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", lead_image_usage_test_type))
    edition = create(:standard_edition, images: [lead_image])
    edition.stubs(:placeholder_image_url).returns(placeholder_image_url)
    lead_usage = edition.permitted_image_usages.find { |usage| usage.key == "lead" }

    render_inline(Admin::EditionImages::LeadImageCardComponent.new(edition:, image: lead_image, image_usage: lead_usage))

    assert_selector ".govuk-summary-list__row:has(.govuk-summary-list__key:contains(\"Image\")) .govuk-summary-list__value", text: "Processing"
  end

  test "renders placeholder image when neither a custom lead image nor a default are available" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", lead_image_usage_test_type))
    placeholder_image_url = "https://assets.publishing.service.gov.uk/media/_ID_/placeholder.jpg"
    edition = create(:standard_edition, images: [], organisations: [create(:organisation, default_news_image: nil)])
    edition.stubs(:placeholder_image_url).returns(placeholder_image_url)
    lead_usage = edition.permitted_image_usages.find { |usage| usage.key == "lead" }

    render_inline(Admin::EditionImages::LeadImageCardComponent.new(edition:, image: nil, image_usage: lead_usage))

    assert_selector "img[src='#{placeholder_image_url}']"
  end

  test "renders placeholder image when default lead image should render but has missing assets" do
    default_lead_image = build(:featured_image_data)
    default_lead_image.assets = []
    default_lead_image.save!
    placeholder_image_url = "https://assets.publishing.service.gov.uk/media/_ID_/placeholder.jpg"

    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", lead_image_usage_test_type))
    edition = create(:standard_edition, images: [], organisations: [create(:organisation, default_news_image: default_lead_image)])
    edition.stubs(:placeholder_image_url).returns(placeholder_image_url)
    lead_usage = edition.permitted_image_usages.find { |usage| usage.key == "lead" }

    render_inline(Admin::EditionImages::LeadImageCardComponent.new(edition:, image: nil, image_usage: lead_usage))

    assert_selector "img[src='#{placeholder_image_url}']"
  end

  test "renders the caption if provided" do
    image_data = create(:image_data, image_kind: "default")
    image = build_stubbed(:image, usage: "lead", image_data:, caption: "Caption Value")
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", lead_image_usage_test_type))
    edition = build_stubbed(:standard_edition, images: [image])
    lead_usage = edition.permitted_image_usages.find { |usage| usage.key == "lead" }

    render_inline(Admin::EditionImages::LeadImageCardComponent.new(edition:, image:, image_usage: lead_usage))

    assert_selector ".govuk-summary-list__row .govuk-summary-list__key", text: "Caption"
    assert_selector ".govuk-summary-list__row .govuk-summary-list__value", text: "Caption Value"
  end

  test "does not render caption when placeholder image is used" do
    default_lead_image = build(:featured_image_data)
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", lead_image_usage_test_type))
    edition = create(:standard_edition, images: [], organisations: [create(:organisation, default_news_image: default_lead_image)])
    lead_usage = edition.permitted_image_usages.find { |usage| usage.key == "lead" }

    render_inline(Admin::EditionImages::LeadImageCardComponent.new(edition:, image: nil, image_usage: lead_usage))

    assert_no_selector ".govuk-summary-list__row .govuk-summary-list__key", text: "Caption"
  end

  test "does not render caption when caption_enabled is false for custom image" do
    image = create(:image, image_data: build(:image_data), caption: "caption")
    edition = build_stubbed(:draft_publication, images: [image])
    render_inline(Admin::EditionImages::LeadImageCardComponent.new(edition:, image:, image_usage: ImageUsage.new(key: "lead", caption_enabled: false)))

    assert_no_selector ".govuk-summary-list__row .govuk-summary-list__key", text: "Caption"
  end

  test "renders placeholder text for caption when none has been provided for custom image" do
    image = build_stubbed(:image, caption: nil)
    edition = build_stubbed(:draft_publication, images: [image])
    render_inline(Admin::EditionImages::LeadImageCardComponent.new(edition:, image:, image_usage: ImageUsage.new(key: "lead", caption_enabled: true)))

    assert_selector ".govuk-summary-list__row .govuk-summary-list__key", text: "Caption"
    assert_selector ".govuk-summary-list__row .govuk-summary-list__value", text: "Not set"
  end

  def lead_image_usage_test_type
    {
      "settings" => {
        "images" => {
          "enabled" => true,
          "usages" => {
            "lead" => {
              "kinds" => %w[default],
              "multiple" => false,
            },
          },
        },
      },
    }
  end
end
