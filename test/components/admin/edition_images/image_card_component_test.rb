# frozen_string_literal: true

require "test_helper"

class Admin::EditionImages::ImageCardComponentTest < ViewComponent::TestCase
  include Rails.application.routes.url_helpers

  test "summary card actions contains Edit and Delete options if image present" do
    image = build_stubbed(:image, caption: "Test caption")
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type"))

    edition = build_stubbed(:draft_standard_edition, images: [image])

    render_inline(Admin::EditionImages::ImageCardComponent.new(edition:, image:, image_usage: ImageUsage.new(key: "test_usage", label: "Test usage")))

    assert_selector ".govuk-link[href='#{edit_admin_edition_image_path(edition, image)}']", text: "Edit"
    assert_selector ".govuk-link[href='#{confirm_destroy_admin_edition_image_path(edition, image)}']", text: "Delete"
  end

  test "summary card actions contains Add option if image not present" do
    image = build_stubbed(:image, caption: "Test caption")
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type"))
    edition = build_stubbed(:draft_standard_edition, images: [image])
    usage = ImageUsage.new(key: "test_usage", label: "Test usage")

    render_inline(Admin::EditionImages::ImageCardComponent.new(edition:, image: nil, image_usage: usage))

    assert_selector ".govuk-link[href='#{new_admin_edition_image_path(edition_id: edition.id, usage: usage.key)}']", text: "Add"
  end

  test "there are no summary card actions if the edition isn't editable" do
    image = build_stubbed(:image, caption: "Test caption")
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type"))
    edition = build_stubbed(:published_standard_edition, images: [image])

    render_inline(Admin::EditionImages::ImageCardComponent.new(edition:, image:, image_usage: ImageUsage.new(key: "test_usage", label: "Test usage")))

    assert_selector ".govuk-link", count: 0
  end

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

  test "does not render caption row when caption_enabled is false" do
    image = build_stubbed(:image, caption: "Test caption")
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type"))
    edition = build_stubbed(:standard_edition, images: [image])

    render_inline(Admin::EditionImages::ImageCardComponent.new(edition:, image:, image_usage: ImageUsage.new(key: "test_usage", label: "Test usage", caption_enabled: false)))

    assert_no_selector ".govuk-summary-list__key", text: "Caption"
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
