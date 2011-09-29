require 'test_helper'

class AttachmentUploaderTest < ActiveSupport::TestCase
  test 'should only allow PDF attachments' do
    uploader = AttachmentUploader.new
    assert_equal %w(pdf), uploader.extension_white_list
  end
end
