# == Schema Information
#
# Table name: unpublishings
#
#  id                     :integer          not null, primary key
#  edition_id             :integer
#  unpublishing_reason_id :integer
#  explanation            :text
#  alternative_url        :text
#  created_at             :datetime
#  updated_at             :datetime
#  document_type          :string(255)
#  slug                   :string(255)
#  redirect               :boolean          default(FALSE)
#

class Unpublishing < ActiveRecord::Base
  belongs_to :edition

  validates :edition, :unpublishing_reason, :document_type, :slug, presence: true
  validates :alternative_url, presence: {
    message: "must be entered if you want to redirect to it",
    if: -> unpublishing { unpublishing.redirect? }
  }

  def self.from_slug(slug, type)
    where(slug: slug, document_type: type.to_s).first
  end

  def unpublishing_reason
    UnpublishingReason.find_by_id unpublishing_reason_id
  end

  def reason_as_sentence
    unpublishing_reason.as_sentence
  end
end
