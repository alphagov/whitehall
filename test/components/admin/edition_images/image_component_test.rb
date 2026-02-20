# frozen_string_literal: true

require "test_helper"

class Admin::EditionImages::ImageComponentTest < ViewComponent::TestCase
  include Rails.application.routes.url_helpers

  test "renders the correct default fields" do
    image = create(:image, image_data: build(:image_data), caption: "caption")
    edition = build_stubbed(:draft_publication, images: [image])
    render_inline(Admin::EditionImages::ImageComponent.new(edition:, image:, image_usage: ImageUsage.new))

    assert_selector ".govuk-grid-row .govuk-grid-column-one-third img[alt='']"
    assert_selector ".govuk-grid-row .govuk-grid-column-two-thirds .govuk-body:nth-child(1)", text: "Caption: caption"
    assert_selector ".app-view-edition-resource__actions a[href='#{edit_admin_edition_image_path(edition, image)}']", text: "Edit details"
    assert_selector ".app-view-edition-resource__actions a[href='#{confirm_destroy_admin_edition_image_path(edition, image)}']", text: "Delete image"
    assert_selector "form[action='#{admin_edition_lead_image_path(edition, image)}']", count: 0
    assert_selector ".govuk-button", text: "Select as lead image", count: 0
  end

  test "renders placeholder text for caption when none has been provided" do
    image = build_stubbed(:image, caption: nil)
    edition = build_stubbed(:draft_publication, images: [image])
    render_inline(Admin::EditionImages::ImageComponent.new(edition:, image:, image_usage: ImageUsage.new))

    assert_selector ".govuk-grid-row .govuk-grid-column-two-thirds .govuk-body:nth-child(1)", text: "Caption: None"
  end

  test "renders a form to the update lead image endpoint for case studies" do
    image = build_stubbed(:image, caption: "caption")
    edition = build_stubbed(:draft_case_study, images: [image])
    render_inline(Admin::EditionImages::ImageComponent.new(edition:, image:, image_usage: ImageUsage.new(key: "govspeak_embed")))

    assert_selector "form[action='#{admin_edition_lead_image_path(edition, image)}']" do
      assert_selector ".govuk-button", text: "Select as lead image"
    end
  end

  test "does not render a button to update the image to the lead image if the image is an SVG for case studies" do
    svg_image_data = build(:image_data, file: File.open(Rails.root.join("test/fixtures/images/test-svg.svg")))
    image = build_stubbed(:image, caption: "caption", image_data: svg_image_data)
    edition = build_stubbed(:draft_case_study, images: [image])
    render_inline(Admin::EditionImages::ImageComponent.new(edition:, image:, image_usage: ImageUsage.new))

    assert_selector ".govuk-button", text: "Select as lead image", count: 0
  end

  test "does not render a button to update the image to the lead image if the image usage is not govspeak_embed" do
    svg_image_data = build(:image_data, file: File.open(Rails.root.join("test/fixtures/images/test-svg.svg")))
    image = build_stubbed(:image, caption: "caption", image_data: svg_image_data)
    edition = build_stubbed(:draft_case_study, images: [image])
    render_inline(Admin::EditionImages::ImageComponent.new(edition:, image:, image_usage: ImageUsage.new))

    assert_selector ".govuk-button", text: "Select as lead image", count: 0
  end

  test "image filename markdown displayed for embeddable usages" do
    jpeg = upload_fixture("images/960x640_jpeg.jpg")
    gif = upload_fixture("images/960x640_gif.gif")
    jpeg_image_data = build_stubbed(:image_data, file: jpeg)
    gif_image_data = build_stubbed(:image_data, file: gif)
    images = [build_stubbed(:image, image_data: jpeg_image_data), build_stubbed(:image, image_data: gif_image_data)]
    edition = build_stubbed(:draft_publication, images:)
    render_inline(Admin::EditionImages::ImageComponent.new(edition:, image: images.first, image_usage: ImageUsage.new(key: "govspeak_embed")))

    assert_selector "input[value='[Image: 960x640_jpeg.jpg]']"
  end

  test "image index markdown used when edition has duplicate image filenames" do
    images = [build_stubbed(:image), build_stubbed(:image)]
    edition = build_stubbed(:draft_publication, images:)
    render_inline(Admin::EditionImages::ImageComponent.new(edition:, image: images.first, image_usage: ImageUsage.new(key: "govspeak_embed")))

    assert_selector "input[value='!!1']"
  end

  test "image index markdown handles a lead image being present correctly" do
    images = [build_stubbed(:image), build_stubbed(:image), build_stubbed(:image)]
    edition = build_stubbed(:draft_case_study, images:, lead_image: images.second)
    render_inline(Admin::EditionImages::ImageComponent.new(edition:, image: images.third, image_usage: ImageUsage.new(key: "govspeak_embed")))

    assert_selector "input[value='!!3']"
  end

  test "renders a processing tag if not all assets of the lead image are uploaded for legacy case studies" do
    image = build_stubbed(:image, image_data: build_stubbed(:image_data_with_no_assets))
    edition = build_stubbed(:draft_case_study, images: [image])

    render_inline(Admin::EditionImages::ImageComponent.new(edition:, image:, image_usage: ImageUsage.new))

    assert_selector ".app-view-edition-resource__preview", count: 0
    assert_selector ".govuk-tag", text: "Processing"
  end
end
