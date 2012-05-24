require 'test_helper'

class EditorialRemarkTest < ActiveSupport::TestCase
  test "should not be valid without a edition" do
    editorial_remark = build(:editorial_remark, edition: nil)
    refute editorial_remark.valid?
  end

  test "should not be valid without a body" do
    editorial_remark = build(:editorial_remark, body: nil)
    refute editorial_remark.valid?
  end

  test "should not be valid without an author" do
    editorial_remark = build(:editorial_remark, author: nil)
    refute editorial_remark.valid?
  end
end