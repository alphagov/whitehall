require "test_helper"

class EditionLeadImageTest < ActiveSupport::TestCase
  test "is invalid without an edition" do
    edition_lead_image = build(:edition_lead_image, edition: nil)
    assert_not edition_lead_image.valid?
  end

  test "is invalid without an image" do
    edition_lead_image = build(:edition_lead_image, image: nil)
    assert_not edition_lead_image.valid?
  end

  test "is invalid when the image is an svg" do
    svg_image_data = build(:image_data, file: File.open(Rails.root.join("test/fixtures/images/test-svg.svg")))
    image = build(:image, image_data: svg_image_data)
    edition_lead_image = build(:edition_lead_image, image: image)

    assert_not edition_lead_image.valid?
    assert_equal "Lead image can not be an SVG.", edition_lead_image.errors.first.full_message
  end
end
