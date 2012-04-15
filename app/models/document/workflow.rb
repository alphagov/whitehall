module Document::Workflow
  extend ActiveSupport::Concern

  module ClassMethods
    def active
      where(arel_table[:state].not_eq('archived'))
    end
  end

  included do
    include ::Transitions
    include ActiveRecord::Transitions

    default_scope where(arel_table[:state].not_eq('deleted'))

    define_model_callbacks :publish, :archive, :delete, only: :after
    set_callback :publish, :after do
      notify_observers :after_publish
    end
    set_callback :archive, :after do
      notify_observers :after_archive
    end
    set_callback :delete, :after do
      notify_observers :after_delete
    end

    after_publish :archive_previous_documents

    auto_scopes = false
    state_machine auto_scopes: auto_scopes do
      state :draft
      state :submitted
      state :rejected
      state :published
      state :archived
      state :deleted

      event :delete, success: -> document { document.run_callbacks(:delete) } do
        transitions from: [:draft, :submitted, :rejected, :published, :archived], to: :deleted,
          guard: lambda { |d| d.draft? || d.submitted? || d.rejected? || d.only_edition? }
      end

      event :submit do
        transitions from: [:draft, :rejected], to: :submitted
      end

      event :reject do
        transitions from: :submitted, to: :rejected
      end

      event :publish, success: -> document { document.run_callbacks(:publish) } do
        transitions from: [:draft, :submitted], to: :published
      end

      event :archive, success: -> document { document.run_callbacks(:archive) } do
        transitions from: :published, to: :archived
      end
    end

    unless auto_scopes
      available_states.each do |state|
        scope state, where(arel_table[:state].eq(state))
      end
    end

    validates_with DocumentHasNoUnpublishedDocumentsValidator, on: :create
    validates_with DocumentHasNoOtherPublishedDocumentsValidator, on: :create
  end

  def archive_previous_documents
    doc_identity.documents.published.each do |document|
      document.archive! unless document == self
    end
  end

  class DocumentHasNoUnpublishedDocumentsValidator < ActiveModel::Validator
    def validate(record)
      if record.doc_identity && (existing_edition = record.doc_identity.unpublished_edition)
        record.errors.add(:base, "There is already an active #{existing_edition.state} edition for this document")
      end
    end
  end

  class DocumentHasNoOtherPublishedDocumentsValidator < ActiveModel::Validator
    def validate(record)
      if record.published? && record.doc_identity && record.doc_identity.documents.published.any?
        record.errors.add(:base, "There is already a published edition for this document")
      end
    end
  end
end
