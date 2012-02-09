require 'test_helper'

class ImageTest < ActiveSupport::TestCase
  test 'should be valid when built from the factory' do
    image = build(:image)
    assert image.valid?
  end

  test 'should be invalid without alt-text for accessibility' do
    image = build(:image, alt_text: nil)
    refute image.valid?
  end

  test "does not destroy image data when if more documents are associated" do
    image = create(:image)
    image_data = image.image_data
    other_image = create(:image, image_data: image_data)

    image_data.expects(:destroy).never
    image.destroy
  end

  test "destroys image data when no documents are associated" do
    image = create(:image)
    image_data = image.image_data

    image_data.expects(:destroy)
    image.destroy
  end
end