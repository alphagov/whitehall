require 'test_helper'

class UnpublishingTest < ActiveSupport::TestCase
  test 'is not valid without an unpublishing reason' do
    unpublishing = build(:unpublishing, unpublishing_reason_id: nil)
    refute unpublishing.valid?
  end

  test 'is not valid without an edition' do
    unpublishing = build(:unpublishing, edition: nil)
    refute unpublishing.valid?
  end

  test 'returns an unpublishing reason' do
    unpublishing = Unpublishing.new(unpublishing_reason_id: 1)
    assert_equal UnpublishingReason::PublishedInError, unpublishing.unpublishing_reason
  end
end
