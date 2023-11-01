# frozen_string_literal: true

require "test_helper"

class Admin::EditionImages::UploadedImagesComponentTest < ViewComponent::TestCase
  test "renders correctly for case studies" do
    images = [build_stubbed(:image), build_stubbed(:image)]
    edition = build_stubbed(:draft_case_study, images:, lead_image: images.first)
    render_inline(Admin::EditionImages::UploadedImagesComponent.new(edition:))

    assert_selector "img", count: 2
    assert_selector "img[alt='Lead image']"
    assert_selector "img[alt='Image 1']"
  end

  test "renders correctly for publications" do
    images = [build_stubbed(:image), build_stubbed(:image)]
    edition = build_stubbed(:draft_publication, images:)
    render_inline(Admin::EditionImages::UploadedImagesComponent.new(edition:))

    assert_selector "img", count: 2
    assert_selector "img[alt='Image 1']"
    assert_selector "img[alt='Image 2']"
  end

  test "renders correctly when edition has no images" do
    edition = build_stubbed(:draft_case_study)
    render_inline(Admin::EditionImages::UploadedImagesComponent.new(edition:))

    assert_selector "img", count: 0
    assert_selector ".govuk-body", text: "No images uploaded"
  end
end
