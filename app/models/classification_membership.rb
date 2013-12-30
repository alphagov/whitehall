class ClassificationMembership < ActiveRecord::Base
  belongs_to :edition
  belongs_to :classification, foreign_key: :classification_id
  belongs_to :topical_event, foreign_key: :classification_id
  belongs_to :topic, foreign_key: :classification_id

  belongs_to :policy, foreign_key: :edition_id
  belongs_to :detailed_guide, foreign_key: :edition_id
  belongs_to :announcement, foreign_key: :edition_id
  belongs_to :news_article, foreign_key: :edition_id
  belongs_to :speech, foreign_key: :edition_id
  belongs_to :publication, foreign_key: :edition_id
  belongs_to :consultation, foreign_key: :edition_id

  # TODO: Validation on join models
  # validates :edition, :classification, presence: true

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
