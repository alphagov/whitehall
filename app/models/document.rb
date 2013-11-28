# All {Edition}s have one document, this model contains the slug and
# handles the logic for slug regeneration.
class Document < ActiveRecord::Base

  extend FriendlyId

  friendly_id :sluggable_string, use: :scoped, scope: :document_type

  after_destroy :destroy_all_editions

  has_many :editions, inverse_of: :document
  has_many :edition_relations, dependent: :destroy

  has_one  :published_edition,
           class_name: 'Edition',
           inverse_of: :document,
           conditions: { state: %w(published archived) }

  has_one  :latest_edition,
           class_name: 'Edition',
           inverse_of: :document,
           conditions: %(
             NOT EXISTS (
               SELECT 1 FROM editions e2
               WHERE e2.document_id = editions.document_id
               AND e2.id > editions.id
               AND e2.state <> 'deleted'))

  has_many :document_sources, dependent: :destroy
  has_many :document_collection_group_memberships
  has_many :document_collection_groups, through: :document_collection_group_memberships
  has_many :document_collections, through: :document_collection_groups
  has_many :features, inverse_of: :document

  delegate :topics, to: :latest_edition

  after_create :ensure_document_has_a_slug

  attr_accessor :sluggable_string

  def self.published
    joins(:published_edition)
  end

  def self.at_slug(document_types, slug)
    where(document_type: document_types, slug: slug).first
  end

  def should_generate_new_friendly_id?
    sluggable_string.present?
  end

  def update_slug_if_possible(new_title)
    return if published?

    candidate_slug = normalize_friendly_id(new_title)
    unless candidate_slug == slug
      update_attributes(sluggable_string: new_title)
    end
  end

  def published?
    published_edition(true).present?
  end

  def first_published_date
    published_edition.first_public_at if published?
  end

  def change_history
    DocumentHistory.new(self)
  end

  def ever_published_editions
    editions.where(state: %w(published superseded))
  end

  def historic_editions
    ever_published_editions.in_reverse_chronological_order
  end

  def scheduled_edition
    editions.scheduled.last
  end

  def non_published_edition
    editions.not_published.last
  end

  private

  def destroy_all_editions
    Edition.unscoped.destroy_all(document_id: self.id)
  end

  def ensure_document_has_a_slug
    if slug.blank?
      update_column(:slug, id.to_s)
    end
  end
end
