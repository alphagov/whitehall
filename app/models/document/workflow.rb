module Document::Workflow
  extend ActiveSupport::Concern

  included do
    include ::Transitions
    include ActiveRecord::Transitions

    default_scope where(%{state <> "deleted"})
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
        transitions from: [:draft, :submitted], to: :deleted
      end

      event :submit do
        transitions from: [:draft, :rejected], to: :submitted
      end

      event :reject do
        transitions from: :submitted, to: :rejected
      end

      event :publish, success: :archive_previous_documents do
        transitions from: [:draft, :submitted], to: :published
      end

      event :archive do
        transitions from: :published, to: :archived
      end
    end

    validates_with DocumentHasNoUnpublishedDocumentsValidator, on: :create
    validates_with DocumentHasNoOtherPublishedDocumentsValidator, on: :create
  end

  def archive_previous_documents
    document_identity.documents.published.each do |document|
      document.archive! unless document == self
    end
  end

  class DocumentHasNoUnpublishedDocumentsValidator < ActiveModel::Validator
    def validate(record)
      if record.document_identity && (record.document_identity.documents.draft.any? || record.document_identity.documents.submitted.any? || record.document_identity.documents.rejected.any?)
        record.errors.add(:base, "There is already an active draft for this document")
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