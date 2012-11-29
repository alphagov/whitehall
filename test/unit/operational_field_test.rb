require "test_helper"

class OperationalFieldTest < ActiveSupport::TestCase
  test "should be invalid without a name" do
    operational_field = build(:operational_field, name: '')
    refute operational_field.valid?
  end

  test "should be invalid without a unique name" do
    existing_operational_field = create(:operational_field)
    new_operational_field = build(:operational_field, name: existing_operational_field.name)
    refute new_operational_field.valid?
  end
end
