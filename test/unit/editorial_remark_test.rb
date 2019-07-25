require 'test_helper'

class EditorialRemarkTest < ActiveSupport::TestCase
  test "should be invalid without a edition" do
    editorial_remark = build(:editorial_remark, edition: nil)
    assert_not editorial_remark.valid?
  end

  test "should be invalid without a body" do
    editorial_remark = build(:editorial_remark, body: nil)
    assert_not editorial_remark.valid?
  end

  test "should be invalid without an author" do
    editorial_remark = build(:editorial_remark, author: nil)
    assert_not editorial_remark.valid?
  end
end
