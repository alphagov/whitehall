require "test_helper"

class Admin::EditionImages::ImageUploadComponentTest < ViewComponent::TestCase
  include Rails.application.routes.url_helpers

  test "uses correct plurality in label" do
    edition = build_stubbed(:draft_publication)

    usage = ImageUsage.new(key: "test_usage", kinds: [Whitehall.image_kinds.fetch("default")], multiple: false)
    render_inline(Admin::EditionImages::ImageUploadComponent.new(edition:, image_usage: usage))
    assert_selector "label", text: "Upload image"

    usage = ImageUsage.new(key: "test_usage", kinds: [Whitehall.image_kinds.fetch("default")], multiple: true)
    render_inline(Admin::EditionImages::ImageUploadComponent.new(edition:, image_usage: usage))
    assert_selector "label", text: "Upload images"
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

  test "renders inline errors for failed images" do
    edition = build_stubbed(:draft_publication)
    usage = ImageUsage.new(key: "test_usage", kinds: [Whitehall.image_kinds.fetch("default")], multiple: false, label: "test")
    failed_image = build(:image, image_data: ImageData.new)
    failed_image.valid?
    render_inline(Admin::EditionImages::ImageUploadComponent.new(edition:, failed_images: [failed_image], image_usage: usage))

    assert_selector ".govuk-form-group--error input[type=\"file\"]"
  end

  test "renders no inline errors when failed_images is empty" do
    edition = build_stubbed(:draft_publication)
    usage = ImageUsage.new(key: "test_usage", kinds: [Whitehall.image_kinds.fetch("default")], multiple: false, label: "test")
    render_inline(Admin::EditionImages::ImageUploadComponent.new(edition:, failed_images: [], image_usage: usage))

    assert_no_selector ".govuk-form-group--error"
  end

  test "does not allow svgs if usage is 'lead'" do
    edition = build_stubbed(:standard_edition)
    usage = ImageUsage.new(key: "lead", kinds: [Whitehall.image_kinds.fetch("default")], multiple: false, label: "lead")

    component = Admin::EditionImages::ImageUploadComponent.new(edition:, image_usage: usage)

    assert_equal "image/png, image/jpeg, image/gif", component.allowed_extensions
  end
end
