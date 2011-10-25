require 'test_helper'

class AttachmentTest < ActiveSupport::TestCase
  test 'should be valid when built from the factory' do
    attachment = build(:attachment)
    assert attachment.valid?
  end

  test 'should be invalid without a file' do
    attachment = build(:attachment, file: nil)
    refute attachment.valid?
  end

  test 'should return filename even after reloading' do
    attachment = create(:attachment)
    refute_nil attachment.filename
    assert_equal attachment.filename, Attachment.find(attachment.id).filename
  end
end