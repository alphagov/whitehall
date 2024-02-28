require "test_helper"

class Edition::LeadImageTest < ActiveSupport::TestCase
  test "should use placeholder image if none had been uploaded" do
    model = stub("Target", lead_image: nil, lead_organisations: [], organisations: []).extend(Edition::LeadImage)
    assert_match %r{placeholder}, model.lead_image_url
    assert_equal "", model.lead_image_alt_text
  end

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

  test "uses unversioned url if the image is an SVG" do
    model = stub("Target", lead_image: nil, lead_organisations: [], organisations: []).extend(Edition::LeadImage)
    file = stub("File", content_type: "image/svg+xml")
    uploader = stub("Uploader", file:)
    image_data = stub("ImageData", file: uploader)
    image = stub("Image", alt_text: "alt_text", image_data:)
    uploader.expects(:url).with.returns("url")
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

  test "#using_default_lead_image? returns true if the lead image is retrieved from an associated lead organisation" do
    organisation = create(:organisation, :with_default_news_image)
    model = stub("Target", lead_image: nil, lead_organisations: [organisation], organisations: []).extend(Edition::LeadImage)

    assert model.using_default_lead_image?
  end

  test "#using_default_lead_image? returns true if the lead image is retrieved from an associated organisation" do
    organisation = create(:organisation, :with_default_news_image)
    model = stub("Target", lead_image: nil, lead_organisations: [], organisations: [organisation]).extend(Edition::LeadImage)

    assert model.using_default_lead_image?
  end

  test "#using_default_lead_image? returns true if the lead image is retrieved from an associated worldwide organisation" do
    worldwide_organisation = create(:worldwide_organisation, :with_default_news_image)
    model = stub("Target", lead_image: nil, lead_organisations: [], organisations: [], worldwide_organisations: [worldwide_organisation]).extend(Edition::LeadImage)

    assert model.using_default_lead_image?
  end

  test "#using_default_lead_image? returns false if the model has a lead image" do
    lead_image = build(:generic_image)
    model = stub("Target", lead_image:, lead_organisations: [], organisations: []).extend(Edition::LeadImage)

    assert_not model.using_default_lead_image?
  end
end
