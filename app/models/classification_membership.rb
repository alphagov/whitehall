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

  validates :edition, :classification, presence: true

  after_create :update_classification_counts
  after_destroy :update_classification_counts

  class << self
    def published
      joins(:edition).where("editions.state" => "published")
    end

    def for_type(type)
      joins(:edition).where("editions.type" => type)
    end
  end

  private

  def update_classification_counts
    classification.update_counts
  end
end
