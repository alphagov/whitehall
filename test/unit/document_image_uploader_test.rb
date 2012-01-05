require 'test_helper'

class DocumentImageUploaderTest < ActiveSupport::TestCase
  test "should only allow JPG or GIF images" do
    uploader = DocumentImageUploader.new
    assert_equal %w(jpg gif), uploader.extension_white_list
  end

  test "should store uploads in a directory that persists across deploys" do
    model = stub("AR Model", id: 1)
    uploader = DocumentImageUploader.new(model, "mounted-as")
    assert_match /^system/, uploader.store_dir
  end
end
