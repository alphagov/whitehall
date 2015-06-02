require "test_helper"

class ClassificationMembershipTest < ActiveSupport::TestCase
  test "should be invalid without an edition" do
    classification_membership = build(:classification_membership, edition: nil)
    refute classification_membership.valid?
  end

  test "should be invalid without classification" do
    classification_membership = build(:classification_membership, classification: nil)
    refute classification_membership.valid?
  end
end
