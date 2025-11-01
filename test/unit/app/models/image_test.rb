require "test_helper"

class ImageTest < ActiveSupport::TestCase
  test "When alt_text is not passed, render with blank alt text for accessibility" do
    image = build(:image, alt_text: nil)
    assert image.valid?
  end

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
end
