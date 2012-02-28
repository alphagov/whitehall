require "test_helper"

class ContactTest < ActiveSupport::TestCase
  test "should be invalid without a description" do
    contact = build(:contact, description: nil)
    refute contact.valid?
  end

  test "should allow creation of nested contact numbers" do
    contact = create(:contact, contact_numbers_attributes: [{label: "Telephone", number: "123"}])
    assert_equal 1, contact.contact_numbers.count
    assert_equal "Telephone", contact.contact_numbers[0].label
    assert_equal "123", contact.contact_numbers[0].number
  end

  test "should not create nested contact numbers if their attributes are blank" do
    contact = create(:contact, contact_numbers_attributes: [{label: "", number: ""}])
    assert_equal 0, contact.contact_numbers.count
  end

  test "should destroy associated contact numbers on destruction" do
    contact = create(:contact, contact_numbers: [create(:contact_number)])
    contact.destroy
    assert contact.contact_numbers.empty?
  end
end