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
end
