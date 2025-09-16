require "test_helper"

class Edition::LeadImageTest < ActiveSupport::TestCase
  test "should use empty string if no alt_text is provided" do
    model = stub("Target", lead_image: nil, lead_organisations: [], organisations: []).extend(Edition::LeadImage)
    file = stub("File", content_type: "image/jpg")
    uploader = stub("Uploader", file:)
    image_data = stub("ImageData", file: uploader)
    image = stub("Image", alt_text: nil, image_data:)
    model.stubs(lead_image: image)
    assert_equal "", model.lead_image_alt_text
  end

  test "should use first image with version :s300 if an image is present" do
    model = stub("Target", lead_image: nil, lead_organisations: [], organisations: []).extend(Edition::LeadImage)
    file = stub("File", content_type: "image/jpg")
    uploader = stub("Uploader", file:)
    image_data = stub("ImageData", file: uploader)
    image = stub("Image", alt_text: "alt_text", image_data:)
    uploader.expects(:url).with(:s300).returns("url")
    model.stubs(lead_image: image)
    assert_equal "url", model.lead_image_url
    assert_equal "alt_text", model.lead_image_alt_text
  end

  test "#lead_image_has_all_assets? returns false if the lead image (ImageData) has missing assets" do
    image_with_missing_assets = build(:image_with_no_assets)
    image_with_missing_assets.image_data.assets << [build(:asset)]

    model = stub("Target", { lead_image: image_with_missing_assets }).extend(Edition::LeadImage)

    assert_not model.lead_image_has_all_assets?
  end

  test "#lead_image_has_all_assets? returns true if the lead image (ImageData) has all assets" do
    image_with_missing_assets = build(:image)

    model = stub("Target", { lead_image: image_with_missing_assets }).extend(Edition::LeadImage)

    assert model.lead_image_has_all_assets?
  end
end
