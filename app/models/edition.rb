# The base class for almost all editoral content.
# @abstract Using STI should not create editions directly.
class Edition < ApplicationRecord
  include Edition::Traits

  include Edition::NullImages
  include Edition::NullWorldLocations

  include Edition::Identifiable
  include Edition::LimitedAccess

  # Adds a statemachine for the publishing workflow. States and methods like
  # `publish` and `withdraw` are defined here.
  include Edition::Workflow

  # Adds support for `unpublishing`, change notes and version numbers.
  include Edition::Publishing

  include AuditTrail

  include Edition::ActiveEditors
  include Edition::Translatable

  # Add support for specialist sector tagging.
  include Edition::SpecialistSectors

  include Dependable

  extend Edition::FindableByOrganisation
  extend Edition::FindableByWorldwideOrganisation

  include Searchable

  has_many :editorial_remarks, dependent: :destroy
  has_many :edition_authors, dependent: :destroy
  has_many :authors, through: :edition_authors, source: :user
  has_many :topical_event_featurings, inverse_of: :edition
  has_many :link_check_reports, as: :link_reportable, class_name: "LinkCheckerApiReport"

  has_many :edition_dependencies, dependent: :destroy
  has_many :depended_upon_contacts, through: :edition_dependencies, source: :dependable, source_type: "Contact"
  has_many :depended_upon_editions, through: :edition_dependencies, source: :dependable, source_type: "Edition"

  validates_with SafeHtmlValidator
  validates_with NoFootnotesInGovspeakValidator, attribute: :body
  validates_with TaxonValidator, on: :publish

  validates :creator, presence: true
  validates :title, presence: true, if: :title_required?, length: { maximum: 255 }
  validates :body, presence: true, if: :body_required?, length: { maximum: 16_777_215 }
  validates :summary, presence: true, if: :summary_required?, length: { maximum: 65_535 }
  validates :first_published_at, recent_date: true, allow_blank: true
  validates :first_published_at, previously_published: true
  validates_each :first_published_at do |record, attr, value|
    record.errors.add(attr, "can't be set to a future date") if value && Time.zone.now < value
  end

  UNMODIFIABLE_STATES = %w[scheduled published superseded deleted].freeze
  FROZEN_STATES = %w[superseded deleted].freeze
  PRE_PUBLICATION_STATES = %w[draft submitted rejected scheduled].freeze
  POST_PUBLICATION_STATES = %w[published superseded withdrawn].freeze
  PUBLICLY_VISIBLE_STATES = %w[published withdrawn].freeze

  scope :with_title_or_summary_containing,
        lambda { |*keywords|
          pattern = "(#{keywords.map { |k| Regexp.escape(k) }.join('|')})"
          in_default_locale.where("edition_translations.title REGEXP :pattern OR edition_translations.summary REGEXP :pattern", pattern:)
        }

  scope :with_title_containing,
        lambda { |keywords|
          escaped_like_expression = keywords.gsub(/([%_])/, "%" => '\\%', "_" => '\\_')
          like_clause = "%#{escaped_like_expression}%"

          in_default_locale
            .includes(:document)
            .where("edition_translations.title LIKE :like_clause OR documents.slug = :slug", like_clause:, slug: keywords)
            .references(:document)
        }

  scope :in_pre_publication_state,      -> { where(state: Edition::PRE_PUBLICATION_STATES) }
  scope :force_published,               -> { where(state: "published", force_published: true) }
  scope :not_published,                 -> { where(state: %w[draft submitted rejected]) }
  scope :without_not_published,         -> { where.not(state: %w[draft submitted rejected]) }

  scope :announcements,                 -> { where(type: Announcement.concrete_descendants.collect(&:name)) }
  scope :consultations,                 -> { where(type: "Consultation") }
  scope :call_for_evidence,             -> { where(type: "CallForEvidence") }
  scope :detailed_guides,               -> { where(type: "DetailedGuide") }
  scope :statistical_publications,      -> { where("publication_type_id IN (?)", PublicationType.statistical.map(&:id)) }
  scope :non_statistical_publications,  -> { where("publication_type_id NOT IN (?)", PublicationType.statistical.map(&:id)) }
  scope :corporate_publications,        -> { where(publication_type_id: PublicationType::CorporateReport.id) }
  scope :corporate_information_pages,   -> { where(type: "CorporateInformationPage") }
  scope :publicly_visible,              -> { where(state: PUBLICLY_VISIBLE_STATES) }

  scope :future_scheduled_editions,     -> { scheduled.where(Edition.arel_table[:scheduled_publication].gteq(Time.zone.now)) }

  scope :latest_edition, -> { joins(:document).where("editions.id = documents.latest_edition_id") }
  scope :live_edition, -> { joins(:document).where("documents.live_edition_id = editions.id") }

  # @!group Callbacks
  before_create :set_auth_bypass_id
  before_save :set_public_timestamp
  after_create :update_document_edition_references
  after_update :update_document_edition_references, if: :saved_change_to_state?
  # @!endgroup

  after_update :republish_topical_event_to_publishing_api

  class UnmodifiableValidator < ActiveModel::Validator
    def validate(record)
      significant_changed_attributes(record).each do |attribute|
        record.errors.add(attribute, "cannot be modified when edition is in the #{record.state} state")
      end
    end

    def significant_changed_attributes(record)
      record.changed - modifiable_attributes(record.state_was, record.state)
    end

    def modifiable_attributes(previous_state, current_state)
      modifiable = %w[state updated_at force_published]
      if previous_state == "scheduled"
        modifiable += %w[major_change_published_at first_published_at access_limited]
      end
      if PRE_PUBLICATION_STATES.include?(previous_state) || being_unpublished?(previous_state, current_state)
        modifiable += %w[published_major_version published_minor_version]
      end
      modifiable
    end

    def being_unpublished?(previous_state, current_state)
      previous_state == "published" && %w[draft withdrawn].include?(current_state)
    end
  end

  validates_with UnmodifiableValidator, if: :unmodifiable?

  def self.alphabetical(locale = I18n.locale)
    with_translations(locale).order("edition_translations.title ASC")
  end

  def self.published_before(date)
    where(arel_table[:public_timestamp].lteq(date))
  end

  def self.published_after(date)
    where(arel_table[:public_timestamp].gteq(date))
  end

  def self.in_chronological_order
    order(arel_table[:public_timestamp].asc, arel_table[:document_id].asc)
  end

  def self.in_reverse_chronological_order
    ids = pluck(:id)
    Edition
      .unscoped
      .where(id: ids)
      .order(
        arel_table[:public_timestamp].desc,
        arel_table[:document_id].desc,
        arel_table[:id].desc,
      )
  end

  def self.without_editions_of_type(*edition_classes)
    where(arel_table[:type].not_in(edition_classes.map(&:name)))
  end

  def self.format_name
    @format_name ||= model_name.human.downcase
  end

  def self.authored_by(user)
    if user && user.id
      where(
        "EXISTS (
        SELECT * FROM edition_authors ea_authorship_check
        WHERE
          ea_authorship_check.edition_id=editions.id
          AND ea_authorship_check.user_id=?
        )",
        user.id,
      )
    end
  end

  def self.by_type_or_subtypes(type, subtypes)
    if subtypes.nil?
      by_type(type)
    elsif subtypes.empty?
      none
    else
      by_subtypes(type, subtypes.pluck(:id))
    end
  end

  def self.by_type(type)
    where(type: type.to_s)
  end

  def self.by_subtype(type, subtype)
    merge(type.by_subtype(subtype))
  end

  def self.by_subtypes(type, subtype_ids)
    merge(type.by_subtypes(subtype_ids))
  end

  def self.in_world_location(world_location)
    joins(:world_locations).where("world_locations.id" => world_location)
  end

  def self.from_date(date)
    where("editions.updated_at >= ?", date)
  end

  def self.to_date(date)
    where("editions.updated_at <= ?", date)
  end

  def self.only_broken_links
    joins(
      "
LEFT JOIN (
  SELECT id, link_reportable_type, link_reportable_id
  FROM link_checker_api_reports
  GROUP BY link_reportable_type, link_reportable_id
  ORDER BY id DESC
) AS latest_link_checker_api_reports
  ON latest_link_checker_api_reports.link_reportable_type = 'Edition'
 AND latest_link_checker_api_reports.link_reportable_id = editions.id",
    ).where(
      "
EXISTS (
  SELECT 1
  FROM link_checker_api_report_links
  WHERE link_checker_api_report_id = latest_link_checker_api_reports.id
    AND link_checker_api_report_links.status != 'ok'
)",
    )
  end

  def self.search_format_type
    name.underscore.tr("_", "-")
  end

  def self.concrete_descendants
    descendants.reject { |model| model.descendants.any? }.sort_by(&:name)
  end

  def self.concrete_descendant_search_format_types
    concrete_descendants.map(&:search_format_type)
  end

  # NOTE: this scope becomes redundant once Admin::EditionFilterer is backed by an admin-only rummager index
  def self.with_topical_event(topical_event)
    joins("INNER JOIN topical_event_memberships ON topical_event_memberships.edition_id = editions.id")
      .where("topical_event_memberships.topical_event_id" => topical_event.id)
  end

  def self.due_for_publication(within_time = 0)
    cutoff = Time.zone.now + within_time
    scheduled.where(arel_table[:scheduled_publication].lteq(cutoff))
  end

  def self.scheduled_for_publication_as(slug)
    document = Document.at_slug(document_type, slug)
    document && document.scheduled_edition
  end

  def attachables
    []
  end

  def skip_main_validation?
    FROZEN_STATES.include?(state)
  end

  def unmodifiable?
    persisted? && UNMODIFIABLE_STATES.include?(state_was)
  end

  def clear_slug
    document.update_slug_if_possible("deleted-#{title(I18n.default_locale)}")
  end

  searchable(
    id: :id,
    title: :search_title,
    link: :search_link,
    format: ->(d) { d.format_name.tr(" ", "_") },
    content: :indexable_content,
    description: :summary,
    people: nil,
    roles: nil,
    display_type: :display_type,
    detailed_format: :detailed_format,
    public_timestamp: :public_timestamp,
    relevant_to_local_government: :relevant_to_local_government?,
    world_locations: nil,
    only: :search_only,
    index_after: [],
    unindex_after: [],
    search_format_types: :search_format_types,
    attachments: nil,
    operational_field: nil,
    latest_change_note: :most_recent_change_note,
    is_political: :political?,
    is_historic: :historic?,
    is_withdrawn: :withdrawn?,
    government_name: :search_government_name,
    content_store_document_type: :content_store_document_type,
  )

  def search_title
    title
  end

  def search_link
    base_path
  end

  def search_format_types
    [Edition.search_format_type]
  end

  def self.publicly_visible_and_available_in_english
    with_translations(:en).publicly_visible
  end

  def self.search_only
    publicly_visible_and_available_in_english
  end

  def refresh_index_if_required
    if document.editions.published.any?
      document.editions.published.last.update_in_search_index
    else
      remove_from_search_index
    end
  end

  def creator
    edition_authors.first&.user
  end

  def creator=(user)
    if new_record?
      edition_author = edition_authors.first || edition_authors.build
      edition_author.user = user
    else
      raise "author can only be set on new records"
    end
  end

  def publicly_visible?
    PUBLICLY_VISIBLE_STATES.include?(state)
  end

  def versioning_completed?
    return true unless change_note_required?

    change_note.present? || minor_change
  end

  # @group Overwritable permission methods
  def can_be_associated_with_topical_events?
    false
  end

  def can_be_associated_with_role_appointments?
    false
  end

  def can_be_associated_with_worldwide_organisations?
    false
  end

  def can_be_fact_checked?
    false
  end

  def can_be_related_to_mainstream_content?
    false
  end

  def can_be_related_to_organisations?
    false
  end

  def can_apply_to_subset_of_nations?
    false
  end

  def allows_attachments?
    false
  end

  def allows_attachment_references?
    false
  end

  def allows_inline_attachments?
    false
  end

  def can_be_grouped_in_collections?
    false
  end

  def has_operational_field?
    false
  end

  def image_disallowed_in_body_text?(_index)
    false
  end

  def can_apply_to_local_government?
    false
  end

  def national_statistic?
    false
  end

  def has_consultation_participation?
    false
  end

  def is_associated_with_a_minister?
    false
  end

  def statistics?
    false
  end

  def can_be_tagged_to_worldwide_taxonomy?
    false
  end

  def path_name
    to_model.class.name.underscore
  end

  def has_been_tagged?
    api_response = Services.publishing_api.get_links(content_id)

    return false if api_response["links"].nil? || api_response["links"]["taxons"].nil?

    api_response["links"]["taxons"].any?
  end

  def included_in_statistics_feed?
    search_format_types.include?("publicationesque-statistics")
  end

  # @!endgroup

  def create_draft(user, allow_creating_draft_from_deleted_edition: false)
    ActiveRecord::Base.transaction do
      lock!
      if allow_creating_draft_from_deleted_edition
        raise "Edition not in the deleted state" unless deleted?
      elsif !published?
        raise "Cannot create new edition based on edition in the #{state} state"
      end

      ignorable_attribute_keys = %w[id
                                    type
                                    state
                                    created_at
                                    updated_at
                                    change_note
                                    minor_change
                                    force_published
                                    scheduled_publication]
      draft_attributes = attributes.except(*ignorable_attribute_keys)
        .merge("state" => "draft", "creator" => user, "previously_published" => previously_published)

      self.class.new(draft_attributes).tap do |draft|
        traits.each { |t| t.process_associations_before_save(draft) }
        if (draft.valid? || !draft.errors.key?(:base)) && draft.save(validate: false)
          traits.each { |t| t.process_associations_after_save(draft) }
        end
      end
    end
  end

  def author_names
    edition_authors.map(&:user).map(&:name).uniq
  end

  def rejected_by
    author_of_latest_state_change_to("rejected")
  end

  def published_by
    versions_desc.where(state: "published").first.try(:user)
  end

  def scheduled_by
    versions_desc.where(state: "scheduled").first.try(:user)
  end

  def submitted_by
    author_of_latest_state_change_to("submitted")
  end

  def title_with_state
    "#{title} (#{state})"
  end

  def indexable_content
    body_without_markup
  end

  def body_without_markup
    Govspeak::Document.new(body).to_text
  end

  def other_editions
    if persisted?
      document.editions.where(self.class.arel_table[:id].not_eq(id))
    else
      document.editions
    end
  end

  def previous_edition
    document.ever_published_editions.where.not(id:).last
  end

  def is_latest_edition?
    document.latest_edition == self
  end

  def all_nation_applicability_selected?
    true
  end

  def most_recent_change_note
    if minor_change?
      previous_major_version = Edition.unscoped.where("document_id=? and published_major_version=? and published_minor_version=0", document_id, published_major_version)
      previous_major_version.first.change_note if previous_major_version.any?
    else
      change_note unless first_published_version?
    end
  end

  def rendering_app
    Whitehall::RenderingApp::WHITEHALL_FRONTEND
  end

  def format_name
    self.class.format_name
  end

  def display_type
    I18n.t("document.type.#{display_type_key}", count: 1)
  end

  def display_type_key
    format_name.tr(" ", "_")
  end

  def first_public_at
    first_published_at
  end

  def make_public_at(date)
    self.first_published_at ||= date
  end

  def alternative_format_contact_email
    nil
  end

  def editable?
    draft? || submitted? || rejected?
  end

  def can_have_some_invalid_data?
    deleted? || superseded?
  end

  attr_accessor :has_previously_published_error

  def set_public_timestamp
    self.public_timestamp = if first_published_version?
                              first_public_at
                            else
                              major_change_published_at
                            end
  end

  def set_auth_bypass_id
    self.auth_bypass_id = SecureRandom.uuid
  end

  def title_required?
    true
  end

  def body_required?
    true
  end

  # 'previously_published' is a transient attribute populated
  # by request parameters, and because it's not persisted it's
  # not converted to a boolean, hence this manual attr writer method.
  # NOTE: This method isn't called when the user fails to select an
  # option for this field and so the value remains nil.
  def previously_published=(value)
    @previously_published = value.to_s == "true"
  end

  def previously_published
    return first_published_at.present? unless new_record?

    @previously_published
  end

  def government
    @government ||= Government.on_date(date_for_government) unless date_for_government.nil?
  end

  def search_government_name
    government.name if government
  end

  def historic?
    return false unless government

    political? && !government.current?
  end

  def withdrawn?
    state == "withdrawn"
  end

  def detailed_format
    display_type.parameterize
  end

  def content_store_document_type
    PublishingApiPresenters.presenter_for(self).document_type
  end

  def has_legacy_tags?
    has_primary_sector? || has_secondary_sectors?
  end

  # For more info, see https://docs.publishing.service.gov.uk/manual/content-preview.html#authentication
  def auth_bypass_token
    JWT.encode(
      {
        "sub" => auth_bypass_id,
        "content_id" => content_id,
        "iat" => Time.zone.now.to_i,
        "exp" => 1.month.from_now.to_i,
      },
      Rails.application.secrets.jwt_auth_secret,
      "HS256",
    )
  end

  def has_enabled_shareable_preview?
    PRE_PUBLICATION_STATES.include?(state)
  end

  # TODO: this can be removed once rails/rails#44770 is released.
  def attribute_names
    @attributes.keys
  end

  def base_path
    url_slug = slug || id.to_param
    "/government/generic-editions/#{url_slug}"
  end

  def public_path(options = {})
    return if base_path.nil?

    append_url_options(base_path, options)
  end

  def public_url(options = {})
    return if base_path.nil?

    website_root = if options[:draft]
                     Plek.external_url_for("draft-origin")
                   else
                     Plek.website_root
                   end

    website_root + public_path(options)
  end

private

  def date_for_government
    published_edition_date = first_public_at.try(:to_date)
    draft_edition_date = updated_at.try(:to_date)
    published_edition_date || draft_edition_date
  end

  def enforcer(user)
    Whitehall::Authority::Enforcer.new(user, self)
  end

  def summary_required?
    true
  end

  def republish_topical_event_to_publishing_api
    topical_event_featurings.each do |topical_event_featuring|
      Whitehall::PublishingApi.republish_async(topical_event_featuring.topical_event)
    end
  end

  def update_document_edition_references
    document.update_edition_references
  end

  def author_of_latest_state_change_to(state)
    # Find this edition's most recent state change to the state passed in.
    # This will tell us when it was most recent transition to this state,
    # even if there were subsequent changes from other users while the
    # document remained in a the same state. Then return it's user.

    latest_version_with_state = versions_desc.select("created_at, id")
                                            .where(state:)
                                            .limit(1)

    previous_version_with_different_state = versions_desc.select("created_at, id")
                                         .where.not(state:)
                                         .where("(created_at, id) < (:latest_version_with_state)", latest_version_with_state:)
                                         .limit(1)

    if latest_version_with_state.present? && previous_version_with_different_state.blank?
      return versions_asc.where(state:).limit(1).first.try(:user)
    end

    first_version_with_state = versions_asc.where(state:)
                                          .where("(created_at, id) > (:previous_version_with_different_state)", previous_version_with_different_state:)
                                          .first

    first_version_with_state.try(:user)
  end
end
