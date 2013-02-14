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
    unpublishing = build(:unpublishing, unpublishing_reason_id: reason.id)
    assert_equal reason, unpublishing.unpublishing_reason
  end

  test 'returns the unpublishing reason as a sentence' do
    assert_equal reason.as_sentence, build(:unpublishing, unpublishing_reason_id: reason.id).reason_as_sentence
  end

  def reason
    UnpublishingReason::PublishedInError
  end
end
