require 'test_helper'

class PersonTest < ActiveSupport::TestCase
  test "should be valid when built from the factory" do
    person = build(:person)
    assert person.valid?
  end

  test "should be invalid without a name" do
    person = build(:person, name: nil)
    refute person.valid?
  end
end