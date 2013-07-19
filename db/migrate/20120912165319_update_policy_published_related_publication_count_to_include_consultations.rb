class Edition < ActiveRecord::Base
end

class Policy < Edition
  has_many :edition_relations, through: :document
  has_many :published_related_publications, through: :edition_relations, source: :edition, conditions: {editions: {type: %w(Publication Consultation), state: 'published'}}
  def update_published_related_publication_count
    update_column(:published_related_publication_count, published_related_publications.count)
  end
end

class UpdatePolicyPublishedRelatedPublicationCountToIncludeConsultations < ActiveRecord::Migration
  def up
    Policy.published.each(&:update_published_related_publication_count)
  end

  def down
    # intentionally left blank
  end
end
