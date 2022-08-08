# All {Edition}s have one document, this model contains the slug and
# handles the logic for slug regeneration.
class Document < ApplicationRecord
  extend FriendlyId

  include Document::Needs
  include LockedDocumentConcern

  friendly_id :sluggable_string, use: :scoped, scope: :document_type

  after_destroy :destroy_all_editions

  has_many :editions,
           -> { order(created_at: :asc, id: :asc) },
           inverse_of: :document
  has_many :edition_relations, dependent: :destroy, inverse_of: :document

  has_one  :live_edition,
           -> { joins(:document).where("documents.live_edition_id = editions.id") },
           class_name: "Edition",
           inverse_of: :document

  has_one  :pre_publication_edition,
           -> { where(state: Edition::PRE_PUBLICATION_STATES) },
           class_name: "Edition",
           inverse_of: :document

  has_one  :latest_edition,
           -> { joins(:document).where("documents.latest_edition_id = editions.id") },
           class_name: "Edition",
           inverse_of: :document

  has_many :document_sources, dependent: :destroy
  has_many :document_collection_group_memberships, inverse_of: :document, dependent: :delete_all
  has_many :document_collection_groups, through: :document_collection_group_memberships
  has_many :document_collections, through: :document_collection_groups
  has_many :features, inverse_of: :document, dependent: :destroy

  has_many :edition_versions, through: :editions, source: :versions
  has_many :editorial_remarks, through: :editions

  has_many :withdrawals,
           -> { where(unpublishing_reason_id: UnpublishingReason::Withdrawn).order(unpublished_at: :asc, id: :asc) },
           through: :editions, source: :unpublishing

  before_save { check_if_locked_document(document: self) unless locked_changed? }

  validates :content_id, presence: true

  after_create :ensure_document_has_a_slug

  attr_accessor :sluggable_string

  def self.live
    joins(:live_edition)
  end

  def self.at_slug(document_types, slug)
    document_types = Array(document_types).map(&:to_s)
    find_by(document_type: document_types, slug: slug)
  end

  def similar_slug_exists?
    scope = Document.where(document_type: document_type)
    sequence_separator = friendly_id_config.sequence_separator

    # slug is a nullable column, so we can't assume that it exists
    return false if slug.nil?

    slug_without_sequence = slug.split(sequence_separator).first

    scope.where(
      "slug IN (?) OR slug LIKE ?",
      [slug, slug_without_sequence].uniq,
      "#{slug_without_sequence}#{sequence_separator}%",
    ).count > 1
  end

  def should_generate_new_friendly_id?
    sluggable_string.present?
  end

  def update_slug_if_possible(new_title)
    return if live?

    candidate_slug = normalize_friendly_id(new_title)
    unless candidate_slug == slug
      update!(sluggable_string: new_title)
    end
  end

  def live?
    live_edition_id.present?
  end

  # this is to support linking to documents which haven't get been published,
  # but will be published within 5 seconds
  def published_very_soon?
    Edition
      .scheduled
      .where("scheduled_publication <= ?", 5.seconds.from_now)
      .exists?(document_id: id)
  end

  def first_published_date
    live_edition.first_public_at if live?
  end

  def first_published_on_govuk
    edition_versions.where(state: "published").pick(:created_at)
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
    document_type.underscore.tr("_", " ")
  end

  def update_edition_references
    latest = editions.reverse_order
    update!(
      latest_edition_id: latest.pick(:id),
      live_edition_id: latest.where(state: Edition::PUBLICLY_VISIBLE_STATES).pick(:id),
    )
  end

private

  def destroy_all_editions
    Edition.unscoped.where(document_id: id).destroy_all
  end

  def ensure_document_has_a_slug
    if slug.blank?
      update_column(:slug, id.to_s)
    end
  end
end
