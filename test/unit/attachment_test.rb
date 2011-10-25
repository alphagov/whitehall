require 'test_helper'

class AttachmentTest < ActiveSupport::TestCase
  test 'should be valid when built from the factory' do
    attachment = build(:attachment)
    assert attachment.valid?
  end

  test 'should be invalid without a name' do
    attachment = build(:attachment, file: nil)
    refute attachment.valid?
  end
end