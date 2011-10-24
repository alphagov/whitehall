require 'test_helper'

class MinisterialRoleTest < ActiveSupport::TestCase
  test "should be valid when built from the factory" do
    ministerial_role = build(:ministerial_role)
    assert ministerial_role.valid?
  end

  test "should set a slug from the ministerial role name" do
    role = create(:ministerial_role, name: 'Prime Minister, Cabinet Office')
    assert_equal 'prime-minister-cabinet-office', role.slug
  end

  test "should not change the slug when the name is changed" do
    role = create(:ministerial_role, name: 'Prime Minister, Cabinet Office')
    role.update_attributes(name: 'Prime Minister')
    assert_equal 'prime-minister-cabinet-office', role.slug
  end
end