require 'test_helper'

class GroupTest < ActiveSupport::TestCase
  test "should be invalid without a name" do
    group = build(:group, name: nil)
    refute group.valid?
  end

  test "should be invalid without an organisation" do
    group = build(:group, organisation: nil)
    refute group.valid?
  end
end
