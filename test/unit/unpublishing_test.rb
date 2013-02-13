require 'test_helper'

class UnpublishingTest < ActiveSupport::TestCase
  test "is not valid without an unpublishing reason" do
    unpublishing = build(:unpublishing, unpublishing_reason_id: nil)
    refute unpublishing.valid?
  end

  test "is not valid without an edition" do
    unpublishing = build(:unpublishing, edition: nil)
    refute unpublishing.valid?
  end
end
