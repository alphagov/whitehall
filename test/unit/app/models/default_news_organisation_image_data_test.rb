require "test_helper"
class DefaultNewsOrganisationImageDataTest < ActiveSupport::TestCase
  test "rejects SVG logo uploads" do
    svg_image = File.open(Rails.root.join("test/fixtures/images/test-svg.svg"))
    default_image_data = build(:default_news_organisation_image_data, file: svg_image)

    assert_not default_image_data.valid?
    assert_includes default_image_data.errors.map(&:full_message), "File You are not allowed to upload \"svg\" files, allowed types: jpg, jpeg, gif, png"
  end

  test "rejects non-image file uploads" do
    non_image_file = File.open(Rails.root.join("test/fixtures/folders.zip"))
    default_image_data = build(:default_news_organisation_image_data, file: non_image_file)

    assert_not default_image_data.valid?
    assert_includes default_image_data.errors.map(&:full_message), "File You are not allowed to upload \"zip\" files, allowed types: jpg, jpeg, gif, png"
  end

  test "accepts valid image uploads" do
    jpg_image = File.open(Rails.root.join("test/fixtures/big-cheese.960x640.jpg"))
    default_image_data = build(:default_news_organisation_image_data, file: jpg_image)

    assert default_image_data
    assert_empty default_image_data.errors
  end
end
