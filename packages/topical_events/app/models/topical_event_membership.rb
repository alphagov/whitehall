class TopicalEventMembership < ApplicationRecord
  belongs_to :edition
  belongs_to :topical_event, inverse_of: :topical_event_memberships

  belongs_to :detailed_guide, foreign_key: :edition_id
  belongs_to :announcement, foreign_key: :edition_id
  belongs_to :news_article, foreign_key: :edition_id
  belongs_to :speech, foreign_key: :edition_id
  belongs_to :publication, foreign_key: :edition_id
  belongs_to :consultation, foreign_key: :edition_id
  belongs_to :call_for_evidence, foreign_key: :edition_id

  def self.published
    joins(:edition).where("editions.state" => "published")
  end

  def self.for_type(type)
    joins(:edition).where("editions.type" => type)
  end

  def edition
    Edition.unscoped { super }
  end
end
