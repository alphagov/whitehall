class Document < ActiveRecord::Base
  include Document::Traits

  include Document::Identifiable
  include Document::AccessControl
  include Document::Workflow
  include Document::Organisations
  include Document::Publishing

  include Rails.application.routes.url_helpers
  include PublicDocumentRoutesHelper

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

  after_publish :update_in_search_index
  after_archive :remove_from_search_index

  UNMODIFIABLE_STATES = %w(published archived deleted).freeze

  def unmodifiable?
    persisted? && UNMODIFIABLE_STATES.include?(state_was)
  end

  def significant_changed_attributes
    changed - %w(state updated_at featured carrierwave_featuring_image)
  end

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

  def can_be_associated_with_policy_areas?
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

  def create_draft(user)
    draft_attributes = attributes.except('state', 'created_at', 'updated_at')
    self.class.new(draft_attributes.merge('state' => 'draft', 'creator' => user)).tap do |draft|
      traits.each { |t| t.process_associations_before_save(draft) }
      if draft.save
        traits.each { |t| t.process_associations_after_save(draft) }
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

  def search_index
    { "title" => title, "link" => public_document_path(self),
      "indexable_content" => body_without_markup, "format" => type.underscore }
  end

  private

  def update_in_search_index
    Rummageable.index(search_index)
  end

  def remove_from_search_index
    Rummageable.delete(public_document_path(self))
  end

  def body_without_markup
    Govspeak::Document.new(body).to_text
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
      where("NOT EXISTS (SELECT 1 from documents d2 where d2.document_identity_id = documents.document_identity_id AND d2.id > documents.id AND d2.state <> 'deleted')")
    end

    def latest_published_edition
      published.where("NOT EXISTS (SELECT 1 from documents d2 where d2.document_identity_id = documents.document_identity_id AND d2.id > documents.id AND d2.state = 'published')")
    end

    def search(query)
      published.where("title LIKE :query", query: "%#{query}%")
    end

    def search_index_published
      published.map(&:search_index)
    end
  end
end
