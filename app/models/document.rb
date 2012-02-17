class Document < ActiveRecord::Base
  include Document::Traits

  include Document::Identifiable
  include Document::AccessControl
  include Document::Workflow
  include Document::Organisations
  include Document::Publishing
  include Document::Images

  include Rails.application.routes.url_helpers
  include PublicDocumentRoutesHelper
  include Searchable

  has_many :editorial_remarks, dependent: :destroy
  has_many :document_authors, dependent: :destroy

  validates :title, :body, :creator, presence: true

  class UnmodifiableOncePublishedValidator < ActiveModel::Validator
    def validate(record)
      if record.unmodifiable?
        record.significant_changed_attributes.each do |attribute|
          record.errors.add(attribute, "cannot be modified when document is in the #{record.state} state")
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
    changed - %w(state updated_at featured carrierwave_featuring_image)
  end

  searchable title: :title, link: -> d { d.public_document_path(d) }, content: :body_without_markup,
    only: :published, index_after: :publish, unindex_after: :archive

  def creator
    document_authors.first && document_authors.first.user
  end

  def creator=(user)
    if new_record?
      document_author = document_authors.first || document_authors.build
      document_author.user = user
    else
      raise "author can only be set on new records"
    end
  end

  def can_be_associated_with_policy_topics?
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

  def has_supporting_pages?
    false
  end

  def has_summary?
    false
  end

  def allows_featuring_image?
    false
  end
  
  def lead_image
    nil
  end

  def create_draft(user)
    unless published?
      raise "Cannot create new edition based on edition in the #{state} state"
    end
    draft_attributes = attributes.except('id', 'type', 'state', 'created_at', 'updated_at', 'change_note')
    self.class.new(draft_attributes.merge('state' => 'draft', 'creator' => user)).tap do |draft|
      traits.each { |t| t.process_associations_before_save(draft) }
      if draft.valid? || !draft.errors.keys.include?(:base)
        if draft.save(validate: false)
          traits.each { |t| t.process_associations_after_save(draft) }
        end
      end
    end
  end

  def save_as(user)
    if save
      document_authors.create!(user: user)
    end
  end

  def edit_as(user, attributes = {})
    assign_attributes(attributes)
    save_as(user)
  end

  def author_names
    document_authors.map(&:user).map(&:name).uniq
  end

  def title_with_state
    "#{title} (#{state})"
  end

  def sluggable_title
    title
  end

  def body_without_markup
    Govspeak::Document.new(body).to_text
  end

  def only_edition?
    document_identity.documents.count == 1
  end

  class << self
    def authored_by(user)
      joins(:document_authors).where(document_authors: {user_id: user}).group(:document_id)
    end

    def by_type(type)
      where(type: type)
    end

    def related_to(document)
      case document
      when Policy
        where(id: document.related_documents.collect(&:id))
      else
        where(id: document.related_policies.collect(&:id))
      end
    end

    def latest_edition
      where("NOT EXISTS (SELECT 1 FROM documents d2 WHERE d2.document_identity_id = documents.document_identity_id AND d2.id > documents.id AND d2.state <> 'deleted')")
    end

    def latest_published_edition
      published.where("NOT EXISTS (SELECT 1 FROM documents d2 WHERE d2.document_identity_id = documents.document_identity_id AND d2.id > documents.id AND d2.state = 'published')")
    end

    def search(query)
      published.where("title LIKE :query", query: "%#{query}%")
    end
  end
end
