class Edition < ActiveRecord::Base
end

class Policy < Edition
  has_many :edition_relations, through: :document
  has_many :published_related_publications, through: :edition_relations, source: :edition, conditions: {editions: {type: 'Publication', state: 'published'}}
  def update_published_related_publication_count
    update_column(:published_related_publication_count, published_related_publications.count)
  end
end

class CacheNumberOfPublishedRelatedPublicationsOnPolicy < ActiveRecord::Migration
  def up
    add_column "editions", "published_related_publication_count", :integer, null: false, default: 0
    Policy.published.each(&:update_published_related_publication_count)
  end

  def down
    remove_column "editions", "published_related_publication_count"
  end
end
