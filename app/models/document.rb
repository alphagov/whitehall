# All {Edition}s have one document, this model contains the slug and
# handles the logic for slug regeneration.
class Document < ApplicationRecord
  extend FriendlyId

  include Document::Needs

  friendly_id :sluggable_string, use: :scoped, scope: :document_type

  after_destroy :destroy_all_editions

  has_many :editions, inverse_of: :document
  has_many :edition_relations, dependent: :destroy, inverse_of: :document

  has_one  :published_edition,
           -> { where(state: Edition::PUBLICLY_VISIBLE_STATES) },
           class_name: 'Edition',
           inverse_of: :document
  has_one  :pre_publication_edition,
           -> { where(state: Edition::PRE_PUBLICATION_STATES) },
           class_name: 'Edition',
           inverse_of: :document

  has_one  :latest_edition,
           -> {
             where(%(
               NOT EXISTS (
               SELECT 1 FROM editions e2
               WHERE e2.document_id = editions.document_id
               AND e2.id > editions.id
               AND e2.state <> 'deleted')))
           },
           class_name: 'Edition',
           inverse_of: :document

  has_many :document_sources, dependent: :destroy
  has_many :document_collection_group_memberships, inverse_of: :document, dependent: :delete_all
  has_many :document_collection_groups, through: :document_collection_group_memberships
  has_many :document_collections, through: :document_collection_groups
  has_many :features, inverse_of: :document, dependent: :destroy

  validates_presence_of :content_id

  # DID YOU MEAN: Policy Area?
  # "Policy area" is the newer name for "topic"
  # (https://www.gov.uk/government/topics)
  # "Topic" is the newer name for "specialist sector"
  # (https://www.gov.uk/topic)
  # You can help improve this code by renaming all usages of this field to use
  # the new terminology.
  delegate :topics, to: :latest_edition

  after_create :ensure_document_has_a_slug

  attr_accessor :sluggable_string

  def self.published
    joins(:published_edition)
  end

  def self.at_slug(document_types, slug)
    document_types = Array(document_types).map(&:to_s)
    where(document_type: document_types, slug: slug).first
  end

  def similar_slug_exists?
    scope = Document.where(document_type: document_type)
    sequence_separator = friendly_id_config.sequence_separator
    slug_without_sequence = slug.split(sequence_separator).first

    scope.where("slug IN (?) OR slug LIKE ?", [slug, slug_without_sequence].uniq,
      slug_without_sequence + sequence_separator + '%').count > 1
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
    reload_published_edition.present?
  end

  def first_published_date
    published_edition.first_public_at if published?
  end

  def change_history
    DocumentHistory.new(self)
  end

  def ever_published_editions
    editions.where(state: Edition::POST_PUBLICATION_STATES)
  end

  def scheduled_edition
    editions.scheduled.last
  end

  def non_published_edition
    editions.not_published.last
  end

  def humanized_document_type
    document_type.underscore.tr('_', ' ')
  end

private

  def destroy_all_editions
    Edition.unscoped.where(document_id: self.id).destroy_all
  end

  def ensure_document_has_a_slug
    if slug.blank?
      update_column(:slug, id.to_s)
    end
  end
end
