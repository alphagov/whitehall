# All {Edition}s have one document, this model contains the slug and
# handles the logic for slug regeneration.
class Document < ActiveRecord::Base

  extend FriendlyId

  friendly_id :sluggable_string, use: :scoped, scope: :document_type

  after_destroy :destroy_all_editions

  has_many :editions
  has_many :edition_relations, dependent: :destroy

  has_one  :published_edition,
           class_name: 'Edition',
           conditions: { state: 'published' }
  has_one  :scheduled_edition,
           class_name: 'Edition',
           conditions: { state: 'scheduled' }
  has_one  :unpublished_edition,
           class_name: 'Edition',
           conditions: { state: %w[ draft submitted rejected ] }
  has_many :ever_published_editions,
           class_name: 'Edition',
           conditions: { state: %w[ published archived ] }

  has_one  :latest_edition,
           class_name: 'Edition',
           conditions: %(
             NOT EXISTS (
               SELECT 1 FROM editions e2
               WHERE e2.document_id = editions.document_id
               AND e2.id > editions.id
               AND e2.state <> 'deleted'))

  has_many :document_sources, dependent: :destroy
  has_many :document_series_membership
  has_many :document_series, through: :document_series_membership

  after_create :ensure_document_has_a_slug

  attr_accessor :sluggable_string

  class Change < Struct.new(:public_timestamp, :note)
    def set_as_first_change
      self.note = "First published." if note.blank?
    end
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
    editions = ever_published_editions.significant_change.by_major_change_published_at

    first_edition = editions.pop
    oldest_change = Change.new(first_published_date, first_edition ? first_edition.change_note : nil)
    oldest_change.set_as_first_change

    editions.map { |e|
      Change.new(e.public_timestamp, e.change_note)
    }.push(oldest_change)
  end

  class << self
    def published
      joins(:published_edition)
    end

    def at_slug(document_types, slug)
      where(document_type: document_types, slug: slug).first
    end
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
