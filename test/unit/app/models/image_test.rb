require "test_helper"

class ImageTest < ActiveSupport::TestCase
  test "is invalid without any image data" do
    image = build(:image, image_data: nil)
    assert_not image.valid?
    assert_equal "must be present", image.errors[:image_data][0]
  end

  test "#url returns the url from the image data" do
    image = create(:image)
    image_data = image.image_data
    image_data.stubs(:file_url).returns("http://example.com/file.jpg")
    assert_equal "http://example.com/file.jpg", image.url
  end

  test "#url accepts similar arguments to file url" do
    data = stub("Image data")
    image = build(:image)
    image.stubs(:image_data).returns(data)
    data.expects(:file_url).with(:s216)
    image.url(:s216)
  end

  test "does not destroy image data when other images are associated with it" do
    image = create(:image)
    image_data = image.image_data
    _other_image = create(:image, image_data:)

    image_data.expects(:destroy).never
    image.destroy!
  end

  test "destroys image data when no images are associated" do
    image = create(:image)
    image_data = image.image_data

    image_data.expects(:destroy!)
    image.destroy!
  end

  test "delegates to image data" do
    image = create(:image)

    assert_equal "minister-of-funk.960x640.jpg", image.filename
    assert_equal "image/jpeg", image.content_type
    assert_equal 960, image.width
    assert_equal 640, image.height
    assert image.bitmap?
    assert_not image.svg?
  end

  test "returns variant url of embed_version if specified in config" do
    image = create(:image)

    image_data = image.image_data

    version = image_data.image_kind_config.versions.first.name

    image_data.image_kind_config.stubs(:embed_version).returns(version)

    assert_equal image.embed_url, image.url(version)
  end

  test "returns original url if embed_version not specified in config" do
    image = create(:image)

    image_data = image.image_data

    image_data.image_kind_config.stubs(:embed_version).returns(nil)

    assert_equal image.embed_url, image.url
  end

  test "returns false for can_be_lead_image? if not bitmap image" do
    image = create(:image, :svg)

    assert_not image.can_be_lead_image?
  end

  test "returns false for can_be_lead_image? if bitmap image that requires crop" do
    image = create(:image)
    image_data = image.image_data
    image_data.stubs(:requires_crop?).returns(true)

    assert_not image.can_be_lead_image?
  end

  test "returns true for can_be_lead_image? if bitmap image that does not require crop" do
    image = create(:image)
    image_data = image.image_data
    image_data.stubs(:requires_crop?).returns(false)

    assert image.can_be_lead_image?
  end

  test "#can_be_used? returns false if bitmap image requires crop" do
    image = create(:image)
    image_data = image.image_data
    image_data.stubs(:requires_crop?).returns(true)

    assert_not image.can_be_used?
  end

  test "#can_be_used? returns true if bitmap image does not require crop" do
    image = create(:image)
    image_data = image.image_data
    image_data.stubs(:requires_crop?).returns(false)

    assert image.can_be_used?
  end

  test "#can_be_used? returns true if svg image" do
    image = create(:image, :svg)

    assert image.can_be_used?
  end

  test "image is invalid without an usage" do
    image = build(:image, usage: nil)
    assert_not image.valid?
    assert_equal "must be specified", image.errors[:usage][0]
  end

  test "#publishing_api_details returns a hash of image details" do
    image = create(:image, :svg, usage: "header", caption: "An SVG image")

    expected_hash = {
      type: "header",
      url: image.url,
      caption: "An SVG image",
      content_type: "image/svg+xml",
    }

    assert_equal expected_hash, image.publishing_api_details
  end
end
