require "test_helper"

class Admin::EditionImages::ImageUploadComponentTest < ViewComponent::TestCase
  include Rails.application.routes.url_helpers

  test "includes label in input label if one is provided" do
    edition = build_stubbed(:draft_publication)
    usage = ImageUsage.new(key: "test_usage", kinds: [Whitehall.image_kinds.fetch("default")], multiple: true, label: "test")
    render_inline(Admin::EditionImages::ImageUploadComponent.new(edition:, image_usage: usage))

    assert_selector "label", text: "Upload test image"
  end

  test "sets multiple attribute to value configured for image usage" do
    edition = build_stubbed(:draft_publication)
    usage = ImageUsage.new(key: "test_usage", kinds: [Whitehall.image_kinds.fetch("default")], multiple: true, label: "test")
    render_inline(Admin::EditionImages::ImageUploadComponent.new(edition:, image_usage: usage))

    assert_selector "input[type=\"file\"][multiple]"
  end

  test "renders hidden usage input" do
    edition = build_stubbed(:draft_publication)
    usage = ImageUsage.new(key: "test_usage", kinds: [Whitehall.image_kinds.fetch("default")], multiple: true, label: "test")
    render_inline(Admin::EditionImages::ImageUploadComponent.new(edition:, image_usage: usage))

    assert_selector "input[name=\"usage\"][value=\"test_usage\"]", visible: false
  end

  test "renders hidden image data kind input for single usage" do
    edition = build_stubbed(:draft_publication)
    usage = ImageUsage.new(key: "test_usage", kinds: [Whitehall.image_kinds.fetch("default")], multiple: false, label: "test")
    render_inline(Admin::EditionImages::ImageUploadComponent.new(edition:, image_usage: usage))

    assert_selector "input[name=\"image_kind\"][value=\"default\"]", visible: false
  end

  test "renders radio button inputs for multiple usage" do
    edition = build_stubbed(:draft_publication)
    image_kinds = [Whitehall.image_kinds.fetch("default"), Whitehall.image_kinds.fetch("landing_page_image")]
    usage = ImageUsage.new(key: "test_usage", kinds: image_kinds, multiple: true, label: "test")
    render_inline(Admin::EditionImages::ImageUploadComponent.new(edition:, image_usage: usage))

    image_kinds.each do |kind|
      assert_selector "input[name=\"image_kind\"][value=\"#{kind.name}\"]"
    end
  end

  test "renders error items for new image" do
    edition = build_stubbed(:draft_publication)
    usage = ImageUsage.new(key: "test_usage", kinds: [Whitehall.image_kinds.fetch("default")], multiple: false, label: "test")
    new_image = build(:image, image_data: ImageData.new)
    new_image.valid?
    render_inline(Admin::EditionImages::ImageUploadComponent.new(edition:, new_image:, image_usage: usage))

    assert_selector ".govuk-form-group--error input[type=\"file\"]"
  end
end
