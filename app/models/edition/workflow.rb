module Edition::Workflow
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

    after_publish :archive_previous_editions

    state_machine auto_scopes: true do
      state :draft
      state :submitted
      state :rejected
      state :scheduled
      state :published
      state :archived
      state :deleted

      event :delete, success: -> edition { edition.run_callbacks(:delete) } do
        transitions from: [:draft, :submitted, :rejected, :scheduled, :published, :archived], to: :deleted,
          guard: lambda { |d| d.deletable? }
      end

      event :submit do
        transitions from: [:draft, :rejected], to: :submitted
      end

      event :reject do
        transitions from: :submitted, to: :rejected
      end

      event :schedule do
        transitions from: [:draft, :submitted], to: :scheduled,
          guard: lambda { |edition| edition.scheduled_publication.present? }
      end

      event :unschedule do
        transitions from: :scheduled, to: :submitted
      end

      event :publish, success: -> edition { edition.run_callbacks(:publish) } do
        transitions from: [:draft, :submitted], to: :published,
          guard: lambda { |edition| edition.scheduled_publication.blank? }
        transitions from: [:scheduled], to: :published
      end

      event :archive, success: -> edition { edition.run_callbacks(:archive) } do
        transitions from: :published, to: :archived
      end
    end

    validates_with EditionHasNoUnpublishedEditionsValidator, on: :create
    validates_with EditionHasNoOtherPublishedEditionsValidator, on: :create
  end

  def archive_previous_editions
    document.editions.published.each do |edition|
      edition.archive! unless edition == self
    end
  end

  def save_as(user)
    if save
      edition_authors.create!(user: user)
      recent_edition_openings.where(editor_id: user).delete_all
    end
  end

  def edit_as(user, attributes = {})
    assign_attributes(attributes)
    save_as(user)
  end

  class EditionHasNoUnpublishedEditionsValidator < ActiveModel::Validator
    def validate(record)
      return unless record.document
      existing_edition = record.document.unpublished_edition
      if existing_edition
        record.errors.add(:base, "There is already an active #{existing_edition.state} edition for this document")
      end
    end
  end

  class EditionHasNoOtherPublishedEditionsValidator < ActiveModel::Validator
    def validate(record)
      if record.published? && record.document && record.document.editions.published.any?
        record.errors.add(:base, "There is already a published edition for this document")
      end
    end
  end
end
