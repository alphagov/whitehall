module Document::Workflow
  extend ActiveSupport::Concern

  included do
    include ::Transitions
    include ActiveRecord::Transitions
    include Rails.application.routes.url_helpers
    include PublicDocumentRoutesHelper
    include ActionView::Helpers::SanitizeHelper

    default_scope where(%{documents.state <> "deleted"})
    scope :draft, where(state: "draft")
    scope :submitted, where(state: "submitted")
    scope :rejected, where(state: "rejected")
    scope :published, where(state: "published")

    state_machine do
      state :draft
      state :submitted
      state :rejected
      state :published
      state :archived
      state :deleted

      event :delete do
        transitions from: [:draft, :submitted, :rejected], to: :deleted
      end

      event :submit do
        transitions from: [:draft, :rejected], to: :submitted
      end

      event :reject do
        transitions from: :submitted, to: :rejected
      end

      event :publish, success: :on_publish_success do
        transitions from: [:draft, :submitted], to: :published
      end

      event :archive, success: :on_archive_success do
        transitions from: :published, to: :archived
      end
    end

    validates_with DocumentHasNoUnpublishedDocumentsValidator, on: :create
    validates_with DocumentHasNoOtherPublishedDocumentsValidator, on: :create
  end

  def on_publish_success
    archive_previous_documents
    update_in_search_index unless instance_of?(Document)
  end

  def on_archive_success
    remove_from_search_index unless instance_of?(Document)
  end

  def archive_previous_documents
    document_identity.documents.published.each do |document|
      document.archive! unless document == self
    end
  end

  def update_in_search_index
    Rummageable.index(search_index)
  end

  def remove_from_search_index
    Rummageable.delete(public_document_path(self))
  end

  def search_index
    { "title" => title, "link" => public_document_path(self), "indexable_content" => body_without_markup }
  end

  def body_without_markup
    sanitize(Govspeak::Document.new(body).to_html, tags: []).strip
  end

  module ClassMethods
    def search_index_published
      published.map(&:search_index)
    end
  end

  class DocumentHasNoUnpublishedDocumentsValidator < ActiveModel::Validator
    def validate(record)
      if record.document_identity && (existing_edition = record.document_identity.unpublished_edition)
        record.errors.add(:base, "There is already an active #{existing_edition.state} edition for this document")
      end
    end
  end

  class DocumentHasNoOtherPublishedDocumentsValidator < ActiveModel::Validator
    def validate(record)
      if record.published? && record.document_identity && record.document_identity.documents.published.any?
        record.errors.add(:base, "There is already a published edition for this document")
      end
    end
  end

end