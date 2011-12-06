require "test_helper"

class DocumentPolicyAreaTest < ActiveSupport::TestCase
  test "should be valid when built from the factory" do
    document_policy_area = build(:document_policy_area)
    assert document_policy_area.valid?
  end

  test "should not be valid without policy" do
    document_policy_area = build(:document_policy_area, policy: nil)
    refute document_policy_area.valid?
  end

  test "should not be valid without policy area" do
    document_policy_area = build(:document_policy_area, policy_area: nil)
    refute document_policy_area.valid?
  end
end