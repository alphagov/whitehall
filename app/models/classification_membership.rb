class ClassificationMembership < ApplicationRecord
  belongs_to :edition
  belongs_to :classification, foreign_key: :classification_id, inverse_of: :classification_memberships
  belongs_to :topical_event, foreign_key: :classification_id

  # DID YOU MEAN: Policy Area?
  # "Policy area" is the newer name for "topic"
  # (https://www.gov.uk/government/topics)
  # "Topic" is the newer name for "specialist sector"
  # (https://www.gov.uk/topic)
  # You can help improve this code by renaming all usages of this field to use
  # the new terminology.
  belongs_to :topic, foreign_key: :classification_id

  belongs_to :detailed_guide, foreign_key: :edition_id
  belongs_to :announcement, foreign_key: :edition_id
  belongs_to :news_article, foreign_key: :edition_id
  belongs_to :speech, foreign_key: :edition_id
  belongs_to :publication, foreign_key: :edition_id
  belongs_to :consultation, foreign_key: :edition_id

  validates :edition, :classification, presence: true

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
