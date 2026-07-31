require "test_helper"

class UnmodifiableValidatorTest < ActiveSupport::TestCase
  test "allows auth_bypass_id to be changed when the edition was scheduled" do
    edition = create(:scheduled_edition, :with_auth_bypass_id)
    edition.auth_bypass_id = SecureRandom.uuid

    assert edition.valid?
  end

  test "still forbids other attributes being changed when the edition was scheduled" do
    edition = create(:scheduled_edition)
    edition.title = "Changed title"

    assert_not edition.valid?
    assert_includes edition.errors[:title], "cannot be modified when edition is in the scheduled state"
  end
end
