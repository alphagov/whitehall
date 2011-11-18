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

  test "should generate user-friendly types" do
    assert_equal "Ministerial", build(:ministerial_role).humanized_type
    assert_equal "Ministerial", MinisterialRole.humanized_type
  end

  test "should not be destroyable when it is responsible for documents" do
    ministerial_role = create(:ministerial_role, documents: [create(:document)])
    refute ministerial_role.destroyable?
    assert_equal false, ministerial_role.destroy
  end

  test "should be destroyable when it has no appointments, organisations or documents" do
    ministerial_role = create(:ministerial_role, role_appointments: [], organisations: [], documents: [])
    assert ministerial_role.destroyable?
    assert ministerial_role.destroy
  end
end