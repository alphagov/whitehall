require "test_helper"

class UnpublishingTest < ActiveSupport::TestCase
  test "#unpublished_at is automatically populated if left blank" do
    unpublishing = create(:unpublishing)
    assert_equal Time.zone.now, unpublishing.unpublished_at
  end

  test "#unpublished_at can be set manually" do
    unpublished_at = 3.weeks.ago
    unpublishing = create(:unpublishing, unpublished_at: unpublished_at)
    assert_equal unpublished_at, unpublishing.unpublished_at
  end
end
