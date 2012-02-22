require 'test_helper'

class ImageDataTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  test 'should be invalid without a file' do
    image_data = build(:image_data, file: nil)
    refute image_data.valid?
  end
end