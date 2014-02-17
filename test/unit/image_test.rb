require 'test_helper'

class ImageTest < ActiveSupport::TestCase
  test 'should be invalid without alt-text for accessibility' do
    image = build(:image, alt_text: nil)
    refute image.valid?
  end

  test 'is invalid without any image data' do
    image = build(:image, image_data: nil)
    refute image.valid?
    assert_equal 'must be present', image.errors[:image_data][0]
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
    other_image = create(:image, image_data: image_data)

    image_data.expects(:destroy).never
    image.destroy
  end

  test "destroys image data when no images are associated" do
    image = create(:image)
    image_data = image.image_data

    image_data.expects(:destroy)
    image.destroy
  end
end
