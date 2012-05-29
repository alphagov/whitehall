require 'test_helper'

class ImageTest < ActiveSupport::TestCase
  test 'should be invalid without alt-text for accessibility' do
    image = build(:image, alt_text: nil)
    refute image.valid?
  end

  test "#url returns the url from the image data" do
    image = create(:image)
    image_data = image.image_data
    image_data.stubs(:file_url).returns("http://example.com/file.jpg")
    assert_equal "http://example.com/file.jpg", image.url
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