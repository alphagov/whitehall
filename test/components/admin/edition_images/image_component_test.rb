# frozen_string_literal: true

require "test_helper"

class Admin::EditionImages::ImageComponentTest < ViewComponent::TestCase
  include Rails.application.routes.url_helpers

  test "renders the correct default fields" do
    image = build_stubbed(:image, image_data: build(:image_data), caption: "caption", alt_text: "alt text")
    edition = build_stubbed(:draft_publication, images: [image])
    render_inline(Admin::EditionImages::ImageComponent.new(edition:, image:, last_image: false))

    assert_selector ".govuk-grid-row .govuk-grid-column-one-third img[alt='Image 1']"
    assert_selector ".govuk-grid-row .govuk-grid-column-two-thirds .govuk-body:nth-child(1)", text: "Caption: caption"
    assert_selector ".govuk-grid-row .govuk-grid-column-two-thirds .govuk-body:nth-child(2)", text: "Alt text: alt text"
    assert_selector "input[value='[Image: minister-of-funk.960x640.jpg]']"
    assert_selector ".app-view-edition-resource__actions a[href='#{edit_admin_edition_image_path(edition, image)}']", text: "Edit details"
    assert_selector ".app-view-edition-resource__actions a[href='#{confirm_destroy_admin_edition_image_path(edition, image)}']", text: "Delete image"
    assert_selector ".app-view-edition-resource__section-break"
    assert_selector "form[action='#{admin_edition_lead_image_path(edition, image)}']", count: 0
    assert_selector ".govuk-button", text: "Select as lead image", count: 0
  end

  test "renders placeholder text for caption and alt text when none has been provided" do
    image = build_stubbed(:image, caption: nil, alt_text: nil)
    edition = build_stubbed(:draft_publication, images: [image])
    render_inline(Admin::EditionImages::ImageComponent.new(edition:, image:, last_image: false))

    assert_selector ".govuk-grid-row .govuk-grid-column-two-thirds .govuk-body:nth-child(1)", text: "Caption: None"
    assert_selector ".govuk-grid-row .govuk-grid-column-two-thirds .govuk-body:nth-child(2)", text: "Alt text: None"
  end

  test "renders a form to the update lead image endpoint for case studies" do
    image = build_stubbed(:image, caption: "caption", alt_text: "alt text")
    edition = build_stubbed(:draft_case_study, images: [image])
    render_inline(Admin::EditionImages::ImageComponent.new(edition:, image:, last_image: false))

    assert_selector "form[action='#{admin_edition_lead_image_path(edition, image)}']" do
      assert_selector ".govuk-button", text: "Select as lead image"
    end
  end

  test "does not render a button to update the image to the lead image if the image is an SVG for case studies" do
    svg_image_data = build(:image_data, file: File.open(Rails.root.join("test/fixtures/images/test-svg.svg")))
    image = build_stubbed(:image, caption: "caption", alt_text: "alt text", image_data: svg_image_data)
    edition = build_stubbed(:draft_case_study, images: [image])
    render_inline(Admin::EditionImages::ImageComponent.new(edition:, image:, last_image: false))

    assert_selector ".govuk-button", text: "Select as lead image", count: 0
  end

  test "image filename markdown displayed" do
    jpeg = upload_fixture("images/960x640_jpeg.jpg")
    gif = upload_fixture("images/960x640_gif.gif")
    jpeg_image_data = build_stubbed(:image_data, file: jpeg)
    gif_image_data = build_stubbed(:image_data, file: gif)
    images = [build_stubbed(:image, image_data: jpeg_image_data), build_stubbed(:image, image_data: gif_image_data)]
    edition = build_stubbed(:draft_publication, images:)
    render_inline(Admin::EditionImages::ImageComponent.new(edition:, image: images.first, last_image: false))

    assert_selector "input[value='[Image: 960x640_jpeg.jpg]']"
  end

  test "image index markdown used when edition has duplicate image filenames" do
    images = [build_stubbed(:image), build_stubbed(:image)]
    edition = build_stubbed(:draft_publication, images:)
    render_inline(Admin::EditionImages::ImageComponent.new(edition:, image: images.first, last_image: false))

    assert_selector "input[value='!!1']"
  end

  test "image index markdown handles a lead image being present correctly" do
    images = [build_stubbed(:image), build_stubbed(:image), build_stubbed(:image)]
    edition = build_stubbed(:draft_news_article, images:, lead_image: images.second)
    render_inline(Admin::EditionImages::ImageComponent.new(edition:, image: images.third, last_image: false))

    assert_selector "input[value='!!3']"
  end

  test "renders a processing tag if not all lead image assets are uploaded" do
    image = build_stubbed(:image, image_data: build_stubbed(:image_data_with_no_assets))
    edition = build_stubbed(:draft_news_article, images: [image])

    render_inline(Admin::EditionImages::ImageComponent.new(edition:, image:, last_image: false))

    assert_selector ".app-view-edition-resource__preview", count: 0
    assert_selector ".govuk-tag", text: "Processing"
  end

  test "does not render a line break if last_image parameter is true " do
    image = build_stubbed(:image)
    edition = build_stubbed(:draft_news_article, images: [image])

    render_inline(Admin::EditionImages::ImageComponent.new(edition:, image:, last_image: true))

    assert_selector ".app-view-edition-resource__section-break", count: 0
  end
end
