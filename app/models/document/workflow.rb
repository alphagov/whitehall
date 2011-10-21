module Document::Workflow
  extend ActiveSupport::Concern

  included do
    include ::Transitions
    include ActiveRecord::Transitions

    scope :draft, where(state: "draft")
    scope :unsubmitted, where(state: "draft", submitted: false)
    scope :submitted, where(state: "draft", submitted: true)
    scope :published, where(state: "published")

    state_machine do
      state :draft
      state :published
      state :archived

      event :publish, success: :archive_previous_documents do
        transitions from: :draft, to: :published
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

  class DocumentHasNoUnpublishedDocumentsValidator
    def validate(record)
      if record.document_identity && record.document_identity.documents.draft.any?
        record.errors.add(:base, "There is already an active draft for this document")
      end
    end
  end

  class DocumentHasNoOtherPublishedDocumentsValidator
    def validate(record)
      if record.published? && record.document_identity && record.document_identity.documents.published.any?
        record.errors.add(:base, "There is already a published edition for this document")
      end
    end
  end

end