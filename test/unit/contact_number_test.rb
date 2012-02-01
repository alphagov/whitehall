require 'test_helper'

class ContactNumberTest < ActiveSupport::TestCase
  test "should be valid when built from the factory" do
    contact_number = build(:contact_number)
    assert contact_number.valid?
  end

  test "should be invalid without a label" do
    contact_number = build(:contact_number, label: nil)
    refute contact_number.valid?
  end

  test "should be invalid without a number" do
    contact_number = build(:contact_number, number: nil)
    refute contact_number.valid?
  end
end