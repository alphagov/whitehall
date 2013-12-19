module Edition::Workflow
  extend ActiveSupport::Concern

  module ClassMethods
    def active
      where(arel_table[:state].not_eq('superseded'))
    end
  end

  included do
    include ActiveRecord::Transitions

    default_scope -> { where(arel_table[:state].not_eq('deleted')) }

    state_machine auto_scopes: true do
      state :imported
      state :draft
      state :submitted
      state :rejected
      state :scheduled
      state :published
      state :superseded
      state :deleted
      state :archived

      event :try_draft do
        transitions from: :imported, to: :draft
      end

      event :back_to_imported do
        transitions from: :draft, to: :imported
      end

      event :convert_to_draft do
        transitions from: :imported, to: :draft, guard: -> edition { edition.valid_as_draft? }
      end

      event :delete do
        transitions from: [:imported, :draft, :submitted, :rejected], to: :deleted
      end

      event :submit do
        transitions from: [:draft, :rejected], to: :submitted
      end

      event :reject do
        transitions from: :submitted, to: :rejected
      end

      event :schedule do
        transitions from: :submitted, to: :scheduled, guard: :scheduled_publication_time_set?
      end

      event :force_schedule do
        transitions from: [:draft, :submitted], to: :scheduled, guard: :scheduled_publication_time_set?
      end

      event :unschedule do
        transitions from: :scheduled, to: :submitted
      end

      event :publish do
        transitions from: [:submitted, :scheduled], to: :published
      end

      event :force_publish do
        transitions from: [:draft, :submitted], to: :published
      end

      event :unpublish do
        transitions from: :published, to: :draft
      end

      event :supersede do
        transitions from: :published, to: :superseded
      end

      event :archive do
        transitions from: :published, to: :archived
      end
    end

    validate :edition_has_no_unpublished_editions, on: :create
  end

  def pre_publication?
    Edition::PRE_PUBLICATION_STATES.include?(state.to_s)
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

  def edition_has_no_unpublished_editions
    return unless document
    if existing_edition = document.non_published_edition
      errors.add(:base, "There is already an active #{existing_edition.state} edition for this document")
    end
  end

private

  def scheduled_publication_time_not_set?
    !scheduled_publication_time_set?
  end

  def scheduled_publication_time_set?
    scheduled_publication.present?
  end
end
