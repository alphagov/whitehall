require 'test_helper'

class FeaturedDocumentImageUploaderTest < ActiveSupport::TestCase
  test "should only allow JPG, GIF or PNG images" do
    uploader = FeaturedDocumentImageUploader.new
    assert_equal %w(jpg gif png), uploader.extension_white_list
  end

  test "should store uploads in a directory that persists across deploys" do
    model = stub("AR Model", id: 1)
    uploader = FeaturedDocumentImageUploader.new(model, "mounted-as")
    assert_match /^system/, uploader.store_dir
  end
end
