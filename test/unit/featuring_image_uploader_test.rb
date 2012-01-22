require 'test_helper'

class FeaturingImageUploaderTest < ActiveSupport::TestCase
  test "should only allow JPG, GIF or PNG images" do
    uploader = FeaturingImageUploader.new
    assert_equal %w(jpg gif png), uploader.extension_white_list
  end

  test "should store uploads in a directory that persists across deploys" do
    model = stub("AR Model", id: 1)
    uploader = FeaturingImageUploader.new(model, "mounted-as")
    assert_match /^system/, uploader.store_dir
  end
end
