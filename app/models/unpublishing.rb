class Unpublishing < ActiveRecord::Base
  belongs_to :edition

  validates :edition, :unpublish_reason, presence: true

  def unpublish_reason
    UnpublishingReason.find_by_id unpublishing_reason_id
  end
end
