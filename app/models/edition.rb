class Edition < ApplicationRecord
  include Edition::Traits

  include Edition::NullImages
  include Edition::NullWorldLocations
  include Edition::NullAttachables

  include Edition::BasePermissionMethods

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

  include Edition::Scopes::Orderable
  include Edition::Scopes::SearchableByTitle
  include Edition::Scopes::FilterableByAuthor
  include Edition::Scopes::FilterableByInvalid
  include Edition::Scopes::FilterableByBrokenLinks
  include Edition::Scopes::FilterableByDate
  include Edition::Scopes::FilterableByTopicalEvent
  include Edition::Scopes::FilterableByType
  include Edition::Scopes::FilterableByWorldLocation
  include Edition::Scopes::FindableByOrganisation

  include Dependable

  include DateValidation

  date_attributes :scheduled_publication, :first_published_at, :delivered_on, :opening_at, :closing_at

  has_many :editorial_remarks, dependent: :destroy
  has_many :edition_authors, dependent: :destroy
  has_many :authors, through: :edition_authors, source: :user
  has_many :topical_event_featurings, inverse_of: :edition
  has_one :link_check_report, class_name: "LinkCheckerApiReport", dependent: :destroy

  has_many :edition_dependencies, dependent: :destroy
  has_many :depended_upon_contacts, through: :edition_dependencies, source: :dependable, source_type: "Contact"
  has_many :depended_upon_editions, through: :edition_dependencies, source: :dependable, source_type: "Edition"

  validates_with SafeHtmlValidator
  validates_with NoFootnotesInGovspeakValidator, attribute: :body
  validates_with LinkCheckReportValidator, on: :publish
  validates_with InternalPathLinksValidator, attribute: :body, on: :publish
  validates_with GovspeakContactEmbedValidator, attribute: :body, on: :publish
  validates_with TaxonValidator, on: :publish, if: :requires_taxon?

  validates :creator, presence: true
  validates :title, presence: true, if: :title_required?, length: { maximum: 255 }
  validates :body, presence: true, if: :body_required?, length: { maximum: 16_777_215 }
  validates :summary, presence: true, if: :summary_required?, length: { maximum: 65_535 }
  validates :previously_published, inclusion: { in: [true, false], message: "You must specify whether the document has been published before" }
  validates :first_published_at, presence: true, if: -> { previously_published || published_major_version }
  validates :first_published_at, inclusion: { in: proc { Date.parse("1900-01-01")..Time.zone.now } }, if: :draft?, allow_blank: true
  validates :scheduled_publication, inclusion: { in: proc { Time.zone.now.. }, message: "must be in the future" }, if: :draft?, allow_blank: true
  validates :political, inclusion: { in: [true, false] }

  UNMODIFIABLE_STATES = %w[scheduled published superseded deleted unpublished].freeze
  FROZEN_STATES = %w[superseded deleted].freeze
  PRE_PUBLICATION_STATES = %w[draft submitted rejected scheduled].freeze
  POST_PUBLICATION_STATES = %w[published superseded withdrawn unpublished].freeze
  PUBLICLY_VISIBLE_STATES = %w[published withdrawn].freeze

  before_create :set_auth_bypass_id
  before_save :set_public_timestamp
  after_validation :update_revalidated_at, if: -> { validation_context == :publish }
  after_create :update_document_edition_references
  after_update :update_document_edition_references, if: :saved_change_to_state?

  after_update :republish_topical_event_to_publishing_api

  accepts_nested_attributes_for :document

  validates_with UnmodifiableValidator, if: :unmodifiable?

  def self.format_name
    @format_name ||= model_name.human.downcase
  end

  def self.concrete_descendants
    descendants.reject { |model| model.descendants.any? }.sort_by(&:name)
  end

  def self.enforcer(user)
    Whitehall::Authority::Enforcer.new(user, self)
  end

  def self.scheduled_for_publication_as(slug)
    document = Document.at_slug(document_type, slug)
    document&.scheduled_edition
  end

  def skip_main_validation?
    FROZEN_STATES.include?(state)
  end

  def update_revalidated_at
    new_value = errors.empty? ? Time.current : nil

    if persisted?
      update_column(:revalidated_at, new_value)
    else
      self.revalidated_at = new_value
    end
  end

  def unmodifiable?
    persisted? && UNMODIFIABLE_STATES.include?(state_was)
  end

  def clear_slug
    document.update_slug_if_possible("deleted-#{title(I18n.default_locale)}")
  end

  def self.publicly_visible_and_available_in_english
    with_translations(:en).publicly_visible
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

  def can_be_marked_political?
    true
  end

  def path_name
    to_model.class.name.underscore
  end

  def has_been_tagged?
    api_response = Services.publishing_api.get_expanded_links(content_id, with_drafts: false)

    return false if api_response["expanded_links"].nil? || api_response["expanded_links"]["taxons"].nil?

    api_response["expanded_links"]["taxons"].any?
  rescue GdsApi::HTTPNotFound
    false
  end

  def create_draft(user, allow_creating_draft_from_deleted_edition: false)
    ActiveRecord::Base.transaction do
      lock!
      if allow_creating_draft_from_deleted_edition
        raise "Edition not in the deleted state" unless deleted?
      elsif !can_supersede?
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

  def image_disallowed_in_body_text?(_index)
    false
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

  delegate :format_name, to: :class

  def new_content_warning; end

  def has_parent_type?
    true
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

  def summary_required?
    true
  end

  def body_required?
    true
  end

  def requires_taxon?
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

  def can_set_previously_published?
    true
  end

  def superseded_at
    versions.find { |v| v.state == "superseded" }&.created_at
  end

  def published_at
    versions.find { |v| v.state == "published" }&.created_at
  end

  def government
    if government_id.present?
      Government.find(government_id)
    elsif date_for_government.present?
      Government.on_date(date_for_government)
    end
  end

  def historic?
    return false unless government

    political? && !government.current?
  end

  def withdrawn?
    state == "withdrawn"
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
      Rails.application.credentials.jwt_auth_secret,
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

    options[:locale] ||= primary_locale
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

  def force_scheduled?
    force_published? && state == "scheduled"
  end

  def can_have_custom_lead_image?
    is_a?(Edition::CustomLeadImage)
  end

  def images_have_unique_filenames?
    names = images.map(&:filename)
    names.uniq.length == names.length
  end

  def associated_documents
    []
  end

  def deleted_associated_documents
    []
  end

private

  def date_for_government
    published_edition_date = first_public_at.try(:to_date)
    draft_edition_date = updated_at.try(:to_date)
    published_edition_date || draft_edition_date
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
