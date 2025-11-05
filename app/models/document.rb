# All {Edition}s have one document, this model contains the slug and
# handles the logic for slug regeneration.
class Document < ApplicationRecord
  extend FriendlyId

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

  after_create :ensure_document_has_a_slug

  accepts_nested_attributes_for :review_reminder, allow_destroy: true

  attr_accessor :sluggable_string

  def self.live
    joins(:live_edition)
  end

  def self.at_slug(document_types, slug)
    document_types = Array(document_types).map(&:to_s)
    find_by(document_type: document_types, slug:)
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

  def similar_slug_exists?
    scope = Document.where(document_type:)
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
    candidate_slug = normalize_friendly_id(new_title)
    unless candidate_slug == slug
      update!(sluggable_string: new_title)
      # when special characters or scipts are used from the non-latin alphabets
      # friendly_id sets the documents slug to nil. This ensures that it
      # retains the default behaviour id of the document as the slug rather than being nil
      # as implemented in the #ensure_document_has_a_slug after_create callback
      ensure_document_has_a_slug
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

  def has_republishable_editions?
    (latest_unpublished_edition || live_edition || pre_publication_edition).present?
  end

  def republishing_actions
    # Returns a list of actions required to republish the document. The
    # implementation logic for these is the responsibility of the
    # `PublishingApiDocumentRepublishingWorker`

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

  class View
    class New
      def self.types_for(user)
        types_hash.select { |_type_key, type_hash| type_hash["klass"].enforcer(user).can?(:create) }
      end

      def self.redirect_path_helper(new_document_type)
        types_hash[new_document_type]["klass"].choose_document_type_form_action
      end

      def self.types_hash
        types = {
          "call_for_evidence" => {
            "klass" => CallForEvidence,
            "hint_text" => "Use this to request people's views when it is not a consultation.",
            "label" => "call_for_evidence".humanize,
          },
          "case_study" => {
            "klass" => CaseStudy,
            "hint_text" => "Use this to share real examples that help users understand a process or an important aspect of government policy covered on GOV.UK.",
            "label" => "case_study".humanize,
          },
          "consultation" => {
            "klass" => Consultation,
            "hint_text" => "Use this for documents requiring a collective agreement across government, and requests for people's view on a question with an outcome.",
            "label" => "consultation".humanize,
          },
          "detailed_guide" => {
            "klass" => DetailedGuide,
            "hint_text" => "Use this to tell users the steps they need to take to complete a clearly defined task. They are usually aimed at specialist or professional audiences.",
            "label" => "detailed_guide".humanize,
          },
          "document_collection" => {
            "klass" => DocumentCollection,
            "hint_text" => "Use this to group related documents on a single page for a specific audience or around a specific theme.",
            "label" => "document_collection".humanize,
          },
          "fatality_notice" => {
            "klass" => FatalityNotice,
            "hint_text" => "Use this to provide official confirmation of the death of a member of the armed forces while on deployment. Ministry of Defence only.",
            "label" => "fatality_notice".humanize,
          },
          "news_article" => {
            "klass" => NewsArticle,
            "hint_text" => "Use this for news story, press release, government response, and world news story.",
            "label" => "news_article".humanize,
          },
          "publication" => {
            "klass" => Publication,
            "hint_text" => "Use this for standalone government documents, white papers, strategy documents, and reports.",
            "label" => "publication".humanize,
          },
          "speech" => {
            "klass" => Speech,
            "hint_text" => "Use this for speeches by ministers or other named spokespeople, and ministerial statements to Parliament.",
            "label" => "speech".humanize,
          },
          "statistical_data_set" => {
            "klass" => StatisticalDataSet,
            "hint_text" => "Use this for data that you publish monthly or more often without analysis.",
            "label" => "statistical_data_set".humanize,
          },
          "worldwide_organisation" => {
            "klass" => WorldwideOrganisation,
            "hint_text" => "Use this to create a new worldwide organisation page. Do not create a worldwide organisation unless you have permission from your managing editor or GOV.UK department lead.",
            "label" => "worldwide_organisation".humanize,
          },
          "landing_page" => {
            "klass" => LandingPage,
            "hint_text" => "EXPERIMENTAL Use this to create landing pages.",
            "label" => "landing_page".humanize,
          },
        }
        if Flipflop.enabled?(:configurable_document_types)
          types["standard_edition"] = {
            "klass" => StandardEdition,
            "hint_text" => "EXPERIMENTAL - DEVELOPERS ONLY Use this to create config-driven documents.",
            "label" => "Standard document",
          }
        end
        types
      end
    end
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
