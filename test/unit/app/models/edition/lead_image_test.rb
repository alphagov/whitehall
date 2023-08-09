require "test_helper"

class Edition::LeadImageTest < ActiveSupport::TestCase
  test "should use placeholder image if none had been uploaded" do
    model = stub("Target", images: [], lead_organisations: [], organisations: []).extend(Edition::LeadImage)
    assert_match %r{placeholder}, model.lead_image_url
    assert_equal "", model.lead_image_alt_text
  end

  test "should use empty string if no alt_text is provided" do
    model = stub("Target", images: [], lead_organisations: [], organisations: []).extend(Edition::LeadImage)
    file = stub("File", content_type: "image/jpg")
    uploader = stub("Uploader", file:)
    image_data = stub("ImageData", file: uploader)
    image = stub("Image", alt_text: nil, image_data:)
    model.stubs(images: [image])
    assert_equal "", model.lead_image_alt_text
  end

  test "should use first image with version :s300 if an image is present" do
    model = stub("Target", images: [], lead_organisations: [], organisations: []).extend(Edition::LeadImage)
    file = stub("File", content_type: "image/jpg")
    uploader = stub("Uploader", file:)
    image_data = stub("ImageData", file: uploader)
    image = stub("Image", alt_text: "alt_text", image_data:)
    uploader.expects(:url).with(:s300).returns("url")
    model.stubs(images: [image])
    assert_equal "url", model.lead_image_url
    assert_equal "alt_text", model.lead_image_alt_text
  end

  test "uses unversioned url if the image is an SVG" do
    model = stub("Target", images: [], lead_organisations: [], organisations: []).extend(Edition::LeadImage)
    file = stub("File", content_type: "image/svg+xml")
    uploader = stub("Uploader", file:)
    image_data = stub("ImageData", file: uploader)
    image = stub("Image", alt_text: "alt_text", image_data:)
    uploader.expects(:url).with.returns("url")
    model.stubs(images: [image])
    assert_equal "url", model.lead_image_url
    assert_equal "alt_text", model.lead_image_alt_text
  end
end
