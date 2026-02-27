# frozen_string_literal: true

require "test_helper"

class Admin::EditionImages::ImageCardComponentTest < ViewComponent::TestCase
  include Rails.application.routes.url_helpers

  test "renders caption" do
    image = build_stubbed(:image, caption: "Test caption")
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type"))
    edition = build_stubbed(:standard_edition, images: [image])

    render_inline(Admin::EditionImages::ImageCardComponent.new(edition:, image:, image_usage: ImageUsage.new(key: "test_usage", label: "Test usage")))

    assert_selector ".govuk-summary-list__row:has(.govuk-summary-list__key:contains(\"Caption\")) .govuk-summary-list__value", text: "Test caption"
  end

  test "renders 'Not set' when caption is missing" do
    image = build_stubbed(:image, caption: nil)
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type"))
    edition = build_stubbed(:standard_edition, images: [image])

    render_inline(Admin::EditionImages::ImageCardComponent.new(edition:, image:, image_usage: ImageUsage.new(key: "test_usage", label: "Test usage")))

    assert_selector ".govuk-summary-list__row:has(.govuk-summary-list__key:contains(\"Caption\")) .govuk-summary-list__value", text: "Not set"
  end

  test "renders the 'PROCESSING' tag when image has missing assets" do
    image_data = build_stubbed(:image_data_with_no_assets, image_kind: "default")
    image = build_stubbed(:image, image_data:)
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type"))
    edition = build_stubbed(:standard_edition, images: [image])

    render_inline(Admin::EditionImages::ImageCardComponent.new(edition:, image:, image_usage: ImageUsage.new(key: "test_usage", label: "Test usage")))

    assert_selector ".govuk-summary-list__row:has(.govuk-summary-list__key:contains(\"Image\")) .govuk-summary-list__value", text: "Processing"
  end

  test "renders the 'Requires crop' tag when the image needs cropping" do
    image_data = create(:image_data, image_kind: "default", file: upload_fixture("images/960x960_jpeg.jpg"))
    image = build_stubbed(:image, image_data:)
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type"))
    edition = build_stubbed(:standard_edition, images: [image])

    render_inline(Admin::EditionImages::ImageCardComponent.new(edition:, image:, image_usage: ImageUsage.new(key: "test_usage", label: "Test usage")))

    assert_selector ".govuk-summary-list__row:has(.govuk-summary-list__key:contains(\"Image\")) .govuk-summary-list__value", text: "Requires crop"
  end

  test "renders the thumbnail for an image" do
    image_data = create(:image_data, image_kind: "default")
    image = build_stubbed(:image, image_data:)
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type"))
    edition = build_stubbed(:standard_edition, images: [image])

    render_inline(Admin::EditionImages::ImageCardComponent.new(edition:, image:, image_usage: ImageUsage.new(key: "test_usage", label: "Test usage")))

    assert_selector "img[src='#{image.thumbnail}']"
  end
end
