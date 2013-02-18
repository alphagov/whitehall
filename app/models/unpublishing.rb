class Unpublishing < ActiveRecord::Base
  belongs_to :edition

  validates :edition, :unpublishing_reason, presence: true

  def unpublishing_reason
    UnpublishingReason.find_by_id unpublishing_reason_id
  end

  def reason_as_sentence
    unpublishing_reason.as_sentence
  end
end
