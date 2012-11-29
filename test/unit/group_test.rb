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

  test "should generate a slug based on its name" do
    group = create(:group, name: 'My Group Name')
    assert_equal 'my-group-name', group.slug
  end

  test "should not change the slug when the name is changed" do
    group = create(:group, name: 'The Best Group Ever')
    group.update_attributes(name: 'The Worst Group Ever')
    assert_equal 'the-best-group-ever', group.reload.slug
  end

  test "should not include apostrophes in slug" do
    group = create(:group, name: "Bob's committee")
    assert_equal 'bobs-committee', group.slug
  end
end
