class Edition < ActiveRecord::Base
  include Edition::Traits

  include Edition::Identifiable
  include Edition::AccessControl
  include Edition::Workflow
  include Edition::Organisations
  include Edition::Publishing
  include Edition::Images
  include Edition::AuditTrail
  include Edition::ActiveEditors

  include Rails.application.routes.url_helpers
  include PublicDocumentRoutesHelper
  include Searchable

  has_many :editorial_remarks, dependent: :destroy
  has_many :edition_authors, dependent: :destroy
  has_many :authors, through: :edition_authors, source: :user

  validates :title, :body, :creator, presence: true

  class UnmodifiableOncePublishedValidator < ActiveModel::Validator
    def validate(record)
      if record.unmodifiable?
        record.significant_changed_attributes.each do |attribute|
          record.errors.add(attribute, "cannot be modified when edition is in the #{record.state} state")
        end
      end
    end
  end

  validates_with UnmodifiableOncePublishedValidator

  UNMODIFIABLE_STATES = %w(published archived deleted).freeze
  FROZEN_STATES = %w(archived deleted).freeze

  def skip_main_validation?
    FROZEN_STATES.include?(state)
  end

  def unmodifiable?
    persisted? && UNMODIFIABLE_STATES.include?(state_was)
  end

  def significant_changed_attributes
    changed - %w(state updated_at featured force_published)
  end

  searchable title: :title, link: -> d { d.public_document_path(d) }, content: :indexable_content,
    only: :published, index_after: [], unindex_after: []

  [:publish, :archive, :delete].each do |event|
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

  def can_be_associated_with_topics?
    false
  end

  def can_be_associated_with_ministers?
    false
  end

  def can_be_associated_with_countries?
    false
  end

  def can_be_fact_checked?
    false
  end

  def can_be_related_to_policies?
    false
  end

  def can_apply_to_subset_of_nations?
    false
  end

  def featurable?
    false
  end

  def allows_attachments?
    false
  end

  def allows_supporting_pages?
    false
  end

  def allows_body_to_be_paginated?
    false
  end

  def has_supporting_pages?
    false
  end

  def has_summary?
    false
  end

  def create_draft(user)
    unless published?
      raise "Cannot create new edition based on edition in the #{state} state"
    end
    draft_attributes = attributes.except(*%w{id type state created_at updated_at change_note minor_change force_published})
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
    rejected_event = last_audit_trail_version_event('rejected')
    rejected_event && rejected_event.actor
  end

  def published_by
    published_event = last_audit_trail_version_event('published')
    published_event && published_event.actor
  end

  def title_with_state
    "#{title} (#{state})"
  end

  def sluggable_title
    title
  end

  def indexable_content
    body_without_markup
  end

  def body_without_markup
    Govspeak::Document.new(body).to_text
  end

  def only_edition?
    document.editions.count == 1
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

  def national_statistic?
    false
  end

  class << self
    def authored_by(user)
      joins(:edition_authors).where(edition_authors: {user_id: user}).group(:edition_id)
    end

    def by_type(type)
      where(type: type)
    end

    def related_to(edition)
      case edition
      when Policy
        where(id: edition.related_editions.collect(&:id))
      else
        where(id: edition.related_policies.collect(&:id))
      end
    end

    def latest_edition
      where("NOT EXISTS (SELECT 1 FROM editions e2 WHERE e2.document_id = editions.document_id AND e2.id > editions.id AND e2.state <> 'deleted')")
    end

    def latest_published_edition
      published.where("NOT EXISTS (SELECT 1 FROM editions e2 WHERE e2.document_id = editions.document_id AND e2.id > editions.id AND e2.state = 'published')")
    end
  end
end
