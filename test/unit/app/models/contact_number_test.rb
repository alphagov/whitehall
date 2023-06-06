require "test_helper"

class ContactNumberTest < ActiveSupport::TestCase
  test "should be invalid without a label" do
    contact_number = build(:contact_number, label: nil)
    assert_not contact_number.valid?
  end

  test "should be invalid without a number" do
    contact_number = build(:contact_number, number: nil)
    assert_not contact_number.valid?
  end
end
