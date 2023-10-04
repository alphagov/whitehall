# frozen_string_literal: true

require "test_helper"

class Admin::EditionImages::UploadedImagesComponentTest < ViewComponent::TestCase
  test "lead image rendered for case study" do
    images = [build_stubbed(:image), build_stubbed(:image)]
    edition = build_stubbed(:draft_case_study, images:)
    render_inline(Admin::EditionImages::UploadedImagesComponent.new(edition:))

    assert_selector "img", count: 2
    assert_selector "img[alt='Lead image']"
    assert_selector "img[alt='Image 1']"
  end

  test "lead image not rendered for publication" do
    images = [build_stubbed(:image), build_stubbed(:image)]
    edition = build_stubbed(:draft_publication, images:)
    render_inline(Admin::EditionImages::UploadedImagesComponent.new(edition:))

    assert_selector "img", count: 2
    assert_selector "img[alt='Image 1']"
    assert_selector "img[alt='Image 2']"
  end

  test "image filename markdown displayed" do
    jpeg = upload_fixture("images/960x640_jpeg.jpg")
    gif = upload_fixture("images/960x640_gif.gif")
    jpeg_image_data = build_stubbed(:image_data, file: jpeg)
    gif_image_data = build_stubbed(:image_data, file: gif)
    images = [build_stubbed(:image, image_data: jpeg_image_data), build_stubbed(:image, image_data: gif_image_data)]
    edition = build_stubbed(:draft_publication, images:)
    render_inline(Admin::EditionImages::UploadedImagesComponent.new(edition:))

    assert_selector "input[value='[Image: 960x640_jpeg.jpg]']"
    assert_selector "input[value='[Image: 960x640_gif.gif]']"
  end

  test "image index markdown used for duplicate filenames" do
    images = [build_stubbed(:image), build_stubbed(:image)]
    edition = build_stubbed(:draft_publication, images:)
    render_inline(Admin::EditionImages::UploadedImagesComponent.new(edition:))

    assert_selector "input[value='!!1']"
    assert_selector "input[value='!!2']"
  end

  test "shows \"Processing\" label where image assets (variants) are still uploading" do
    lead_image_data_with_no_assets = build(:image_data, use_non_legacy_endpoints: true)
    regular_image_data_with_no_assets = build(:image_data, use_non_legacy_endpoints: true)
    regular_image_data_with_assets = build(:image_data_with_assets)
    images = [
      build_stubbed(:image, image_data: lead_image_data_with_no_assets),
      build_stubbed(:image, image_data: regular_image_data_with_no_assets),
      build_stubbed(:image, image_data: regular_image_data_with_assets),
    ]
    edition = build_stubbed(:draft_publication, images:)

    render_inline(Admin::EditionImages::UploadedImagesComponent.new(edition:))

    assert_text "Processing", count: 2
  end
end
