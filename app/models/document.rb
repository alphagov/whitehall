class Document < ApplicationRecord
  self.ignored_columns += [:slug]
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

  has_many :document_collection_group_memberships, inverse_of: :document, dependent: :delete_all
  has_many :document_collection_groups, through: :document_collection_group_memberships
  has_many :document_collections, through: :document_collection_groups
  has_many :features, inverse_of: :document, dependent: :destroy

  has_many :edition_versions, through: :editions, source: :versions
  has_many :editorial_remarks, through: :editions

  has_one :review_reminder, inverse_of: :document, dependent: :destroy

  has_many :withdrawals,
           -> { where(unpublishing_reason_id: UnpublishingReason::Withdrawn).order(unpublished_at: :asc, id: :asc) },
           through: :editions, source: :unpublishing

  validates :content_id, presence: true

  accepts_nested_attributes_for :review_reminder, allow_destroy: true

  def self.live
    joins(:live_edition)
  end

  def remarks_by_ids(remark_ids)
    editorial_remarks.where(id: remark_ids).index_by(&:id)
  end

  def active_edition_versions
    edition_versions.where.not(state: "superseded")
  end

  def decorated_edition_versions_by_ids(version_ids)
    versions = active_edition_versions.where(id: version_ids)

    versions.map.with_index { |version, index|
      version = Document::PaginatedTimeline::VersionDecorator.new(
        version,
        is_first_edition: version.item_id == first_edition_id,
        previous_version: versions[index - 1],
      )
      [version.id, version]
    }.to_h
  end

  def first_edition_id
    @first_edition_id ||= editions.pick(:id)
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

  def has_republishable_editions?
    (latest_unpublished_edition || live_edition || pre_publication_edition).present?
  end

  def republishing_actions
    # Returns a list of actions required to republish the document. The
    # implementation logic for these is the responsibility of the
    # `PublishingApiDocumentRepublishingJob`

    return [] unless has_republishable_editions?

    if latest_unpublished_edition.present?
      return [
        :republish_latest_unpublished_edition,
        (:republish_pre_publication_edition if pre_publication_edition&.valid?),
      ].compact
    elsif withdrawn_edition.present?
      return %i[patch_links republish_withdrawn_edition]
    end

    [
      :patch_links,
      (:republish_published_edition if published_edition.present?),
      (:republish_pre_publication_edition if pre_publication_edition&.valid?),
    ].compact
  end

  def republishable_editions
    republishing_actions.map { |action|
      {
        patch_links: nil,
        republish_latest_unpublished_edition: latest_unpublished_edition,
        republish_pre_publication_edition: pre_publication_edition,
        republish_published_edition: published_edition,
        republish_withdrawn_edition: withdrawn_edition,
      }[action]
    }.compact
  end

  def latest_unpublished_edition
    editions.unpublished.last
  end

  def published_edition
    live_edition if live_edition&.state == "published"
  end

  def withdrawn_edition
    live_edition if live_edition&.state == "withdrawn"
  end

private

  def destroy_all_editions
    Edition.unscoped.where(document_id: id).destroy_all
  end
end
