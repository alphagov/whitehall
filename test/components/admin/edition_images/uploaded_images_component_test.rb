# frozen_string_literal: true

require "test_helper"

class Admin::EditionImages::UploadedImagesComponentTest < ViewComponent::TestCase
  test "lead image rendered for case study" do
    images = [build(:image), build(:image)]
    edition = create(:draft_case_study, images:)
    render_inline(Admin::EditionImages::UploadedImagesComponent.new(edition:))

    assert_selector "img", count: 2
    assert_selector "img[alt='Lead image']"
    assert_selector "img[alt='Image 1']"
  end

  test "lead image not rendered for publication" do
    images = [build(:image), build(:image)]
    edition = create(:draft_publication, images:)
    render_inline(Admin::EditionImages::UploadedImagesComponent.new(edition:))

    assert_selector "img", count: 2
    assert_selector "img[alt='Image 1']"
    assert_selector "img[alt='Image 2']"
  end

  test "image filename markdown displayed" do
    jpeg = upload_fixture("images/960x640_jpeg.jpg")
    gif = upload_fixture("images/960x640_gif.gif")
    jpeg_image_data = create(:image_data, file: jpeg)
    gif_image_data = create(:image_data, file: gif)
    images = [build(:image, image_data: jpeg_image_data), build(:image, image_data: gif_image_data)]
    edition = create(:draft_publication, images:)
    render_inline(Admin::EditionImages::UploadedImagesComponent.new(edition:))

    assert_selector "li", text: "[Image: 960x640_jpeg.jpg]"
    assert_selector "li", text: "[Image: 960x640_gif.gif]"
  end

  test "image index markdown used for duplicate filenames" do
    images = [build(:image), build(:image)]
    edition = create(:draft_publication, images:)
    render_inline(Admin::EditionImages::UploadedImagesComponent.new(edition:))

    assert_selector "li", text: "!!1"
    assert_selector "li", text: "!!2"
  end
end
