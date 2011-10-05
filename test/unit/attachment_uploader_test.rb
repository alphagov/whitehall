require 'test_helper'

class AttachmentUploaderTest < ActiveSupport::TestCase
  test 'should only allow PDF attachments' do
    uploader = AttachmentUploader.new
    assert_equal %w(pdf), uploader.extension_white_list
  end
  test "should store uploads in a directory that persists across deploys" do
    model = stub("AR Model", id: 1)
    uploader = AttachmentUploader.new(model, "mounted-as")
    assert_match /^system/, uploader.store_dir
  end
end
