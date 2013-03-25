class Edition < ActiveRecord::Base
  include Edition::Traits

  include Edition::NullImages
  include Edition::NullWorldLocations

  include Edition::Identifiable
  include Edition::AccessControl
  include Edition::LimitedAccess
  include Edition::Workflow
  include Edition::Organisations
  include Edition::Publishing
  include Edition::ScheduledPublishing
  include Edition::AuditTrail
  include Edition::ActiveEditors
  include Edition::Translatable

  include Rails.application.routes.url_helpers
  include PublicDocumentRoutesHelper
  include Searchable

  has_many :editorial_remarks, dependent: :destroy
  has_many :edition_authors, dependent: :destroy
  has_many :authors, through: :edition_authors, source: :user

  has_many :featurings, class_name: "Feature"

  validates_with SafeHtmlValidator
  validates :title, :creator, presence: true
  validates :body, presence: true, if: :body_required?
  validates :summary, presence: true


  scope :with_title_or_summary_containing, -> *keywords {
    pattern = "(#{keywords.map { |k| Regexp.escape(k) }.join('|')})"
    in_default_locale.where("edition_translations.title REGEXP :pattern OR edition_translations.summary REGEXP :pattern", pattern: pattern)
  }

  scope :with_title_containing, -> *keywords {
    pattern = "(#{keywords.map { |k| Regexp.escape(k) }.join('|')})"
    in_default_locale.where("edition_translations.title REGEXP :pattern", pattern: pattern)
  }

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
    order(arel_table[:public_timestamp].desc, arel_table[:document_id].desc)
  end

  def self.without_editions_of_type(*edition_classes)
    where(arel_table[:type].not_in(edition_classes.map(&:name)))
  end

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
      modifiable = %w{state updated_at force_published}
      if previous_state == 'scheduled'
        modifiable += %w{major_change_published_at first_published_at access_limited}
      end
      if PRE_PUBLICATION_STATES.include?(previous_state) || being_unpublished?(previous_state, current_state)
        modifiable += %w{published_major_version published_minor_version}
      end
      modifiable
    end

    def being_unpublished?(previous_state, current_state)
      previous_state == 'published' && current_state == 'draft'
    end
  end

  validates_with UnmodifiableValidator, if: :unmodifiable?

  before_save :set_public_timestamp

  after_unpublish :reset_force_published_flag

  UNMODIFIABLE_STATES = %w(scheduled published archived deleted).freeze
  FROZEN_STATES = %w(archived deleted).freeze
  PRE_PUBLICATION_STATES = %w(imported draft submitted rejected scheduled).freeze

  def skip_main_validation?
    FROZEN_STATES.include?(state)
  end

  def unmodifiable?
    persisted? && UNMODIFIABLE_STATES.include?(state_was)
  end

  searchable(
    id: :id,
    title: :title,
    link: -> d { d.public_document_path(d) },
    format: -> d { d.format_name.gsub(" ", "_") },
    content: :indexable_content,
    description: :summary,
    section: :section,
    subsection: :subsection,
    subsubsection: :subsubsection,
    organisations: -> d { d.organisations.map(&:slug) },
    people: nil,
    display_type: -> d { d.display_type },
    public_timestamp: :public_timestamp,
    relevant_to_local_government: :relevant_to_local_government,
    world_locations: nil,
    topics: nil,
    only: :published,
    index_after: [],
    unindex_after: [],
    search_format_types: -> d { d.search_format_types }
  )

  def search_format_types
    [Edition.search_format_type]
  end
  def self.search_format_type
    self.name.underscore.gsub('_', '-')
  end
  def self.concrete_descendant_search_format_types
    descendants.reject { |model| model.descendants.any? }.map { |model| model.search_format_type }
  end

  [:publish, :unpublish, :archive, :delete].each do |event|
    set_callback(event, :after) { refresh_index_if_required }
  end

  def refresh_index_if_required
    if document.editions.published.any?
      document.editions.published.last.update_in_search_index
    else
      remove_from_search_index
    end
  end

  def creator
    edition_authors.first && edition_authors.first.user
  end

  def creator=(user)
    if new_record?
      edition_author = edition_authors.first || edition_authors.build
      edition_author.user = user
    else
      raise "author can only be set on new records"
    end
  end

  def last_author
    last_version = versions.last
    last_version && last_version.user
  end

  def can_be_associated_with_topics?
    false
  end

  def can_be_associated_with_topical_events?
    false
  end

  def can_be_associated_with_ministers?
    false
  end

  def can_be_associated_with_role_appointments?
    false
  end

  def can_be_associated_with_worldwide_priorities?
    false
  end

  def can_be_associated_with_statistical_data_sets?
    false
  end

  def can_be_associated_with_worldwide_organisations?
    false
  end

  def can_be_fact_checked?
    false
  end

  def can_be_related_to_policies?
    false
  end

  def can_be_related_to_mainstream_content?
    false
  end

  def can_be_associated_with_mainstream_categories?
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

  def allows_supporting_pages?
    false
  end

  def has_supporting_pages?
    false
  end

  def can_be_grouped_in_series?
    false
  end

  def has_operational_field?
    false
  end

  def image_disallowed_in_body_text?(i)
    false
  end

  def can_apply_to_local_government?
    false
  end

  def create_draft(user)
    unless published?
      raise "Cannot create new edition based on edition in the #{state} state"
    end
    draft_attributes = attributes.except(*%w{id type state created_at updated_at change_note
      minor_change force_published scheduled_publication})
    self.class.new(draft_attributes.merge('state' => 'draft', 'creator' => user)).tap do |draft|
      traits.each { |t| t.process_associations_before_save(draft) }
      if draft.valid? || !draft.errors.keys.include?(:base)
        if draft.save(validate: false)
          traits.each { |t| t.process_associations_after_save(draft) }
        end
      end
    end
  end

  def author_names
    edition_authors.map(&:user).map(&:name).uniq
  end

  def rejected_by
    rejected_event = latest_version_audit_entry_for('rejected')
    rejected_event && rejected_event.actor
  end

  def published_by
    published_event = latest_version_audit_entry_for('published')
    published_event && published_event.actor
  end

  def scheduled_by
    scheduled_event = latest_version_audit_entry_for('scheduled')
    scheduled_event && scheduled_event.actor
  end

  def title_with_state
    "#{title} (#{state})"
  end

  def indexable_content
    body_without_markup
  end

  def section
    nil
  end

  def subsection
    nil
  end

  def subsubsection
    nil
  end

  def body_without_markup
    Govspeak::Document.new(body).to_text
  end

  def other_editions
    if self.persisted?
      document.editions.where(self.class.arel_table[:id].not_eq(self.id))
    else
      document.editions
    end
  end

  def other_draft_editions
    other_editions.draft
  end

  def latest_edition
    document.editions.latest_edition.first
  end

  def latest_published_edition
    document.editions.latest_published_edition.first
  end

  def is_latest_edition?
    latest_edition == self
  end

  def most_recent_change_note
    unless first_published_version?
      # Change notes are only on major published versions
      if minor_change?
        previous_major_version = Edition.unscoped.where( 'document_id=? and published_major_version=? and published_minor_version=0', document_id, published_major_version )
        recent_change_note = previous_major_version.first.change_note if previous_major_version.any?
      else
        recent_change_note = change_note
      end
    end
    recent_change_note
  end

  def national_statistic?
    false
  end

  def format_name
    self.class.format_name
  end

  def display_type
    format_name.capitalize
  end

  def display_type_key
    format_name.underscore
  end

  def first_public_at
    first_published_at
  end

  def make_public_at(date)
    self.first_published_at ||= date
  end

  def first_published_date
    first_published_at
  end

  def alternative_format_contact_email
    nil
  end

  def has_consultation_participation?
    false
  end

  def reset_force_published_flag
    update_attribute(:force_published, false)
  end

  class << self
    def format_name
      @format_name ||= model_name.human.downcase
    end

    def authored_by(user)
      if user && user.id
        where("EXISTS (
          SELECT * FROM edition_authors ea_authorship_check
          WHERE
            ea_authorship_check.edition_id=editions.id
            AND ea_authorship_check.user_id=?
          )", user.id)
      end
    end

    def by_type(type)
      where(type: type)
    end

    def in_world_location(world_location)
      joins(:world_locations).where('world_locations.id' => world_location)
    end

    def related_to(edition)
      related = if edition.is_a?(Policy)
        edition.related_editions
      else
        edition.related_policies
      end

      # This works around a wierd bug in ActiveRecord where an outer scope applied
      # to Edition would be applied to this association. See EditionActiveRecordBugWorkaroundTest.
      all_after_forcing_query_execution = related.all
      where(id: all_after_forcing_query_execution.collect(&:id))
    end

    def latest_edition
      where("NOT EXISTS (
        SELECT 1
          FROM editions e2
         WHERE e2.document_id = editions.document_id
           AND e2.id > editions.id
           AND e2.state <> 'deleted')")
    end

    def latest_published_edition
      published.where("NOT EXISTS (
        SELECT 1
          FROM editions e2
         WHERE e2.document_id = editions.document_id
           AND e2.id > editions.id
           AND e2.state = 'published')")
    end
  end

  def valid_as_draft?
    errors_as_draft.empty?
  end

  def errors_as_draft
    if imported?
      begin
        self.apply_any_extra_validations_when_converting_from_imported_to_draft
        self.try_draft
        return valid? ? [] : errors
      ensure
        self.back_to_imported
      end
    else
      valid? ? [] : errors
    end
  end

  def apply_any_extra_validations_when_converting_from_imported_to_draft
  end

  def set_public_timestamp
    if first_published_version?
      self.public_timestamp = first_public_at
    else
      self.public_timestamp = major_change_published_at
    end
  end

  private

  def enforcer(user)
    Whitehall::Authority::Enforcer.new(user, self)
  end

  def body_required?
    true
  end

end
