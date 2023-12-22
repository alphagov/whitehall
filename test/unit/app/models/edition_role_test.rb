require "test_helper"

class EditionRoleTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  test "should be invalid without an edition" do
    edition_role = build(:edition_role, edition: nil)
    assert_not edition_role.valid?
    assert edition_role.errors[:edition].present?
  end

  test "should be invalid without an role" do
    edition_role = build(:edition_role, role: nil)
    assert_not edition_role.valid?
    assert edition_role.errors[:role].present?
  end
end
