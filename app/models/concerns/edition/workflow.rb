module Edition::Workflow
  extend ActiveSupport::Concern

  module ClassMethods
    def active
      where(arel_table[:state].not_eq("superseded"))
    end

    def in_state(state)
      valid_state?(state) && public_send(state)
    end

    def valid_state?(state)
      %w[active draft submitted rejected published scheduled force_published withdrawn not_published unpublished].include?(state)
    end
  end

  included do
    include ActiveRecord::Transitions

    default_scope -> { where(arel_table[:state].not_eq("deleted")) }

    state_machine auto_scopes: true do
      state :draft
      state :submitted
      state :rejected
      state :scheduled
      state :published
      state :superseded
      state :deleted
      state :withdrawn
      state :unpublished

      event :delete do
        transitions from: %i[draft submitted rejected], to: :deleted
      end

      event :submit do
        transitions from: %i[draft rejected], to: :submitted
      end

      event :reject do
        transitions from: :submitted, to: :rejected
      end

      event :schedule do
        transitions from: :submitted, to: :scheduled
      end

      event :force_schedule do
        transitions from: %i[draft submitted], to: :scheduled
      end

      event :unschedule do
        transitions from: :scheduled, to: :submitted
      end

      event :publish do
        transitions from: %i[submitted scheduled], to: :published
      end

      event :force_publish do
        transitions from: %i[draft submitted], to: :published
      end

      event :unpublish do
        transitions from: %i[published unpublished], to: :unpublished
      end

      event :supersede, success: :destroy_associations_with_edition_dependencies_and_dependants do
        transitions from: %i[published unpublished], to: :superseded
      end

      event :withdraw do
        transitions from: %i[published withdrawn], to: :withdrawn
      end

      event :unwithdraw do
        transitions from: :withdrawn, to: :superseded
      end
    end

    validate :edition_has_no_unpublished_editions, on: :create

    scope :in_pre_publication_state, -> { where(state: Edition::PRE_PUBLICATION_STATES) }
    scope :force_published, -> { where(state: "published", force_published: true) }
    scope :not_published, -> { where(state: %w[draft submitted rejected]) }
    scope :without_not_published, -> { where.not(state: %w[draft submitted rejected]) }
    scope :publicly_visible, -> { where(state: Edition::PUBLICLY_VISIBLE_STATES) }
    scope :scheduled, -> { where(state: "scheduled") }

    scope :future_scheduled_editions, -> { scheduled.where(Edition.arel_table[:scheduled_publication].gteq(Time.zone.now)) }
    scope :due_for_publication, lambda { |within_time = 0|
      cutoff = Time.zone.now + within_time
      scheduled.where(arel_table[:scheduled_publication].lteq(cutoff))
    }
  end

  def pre_publication?
    Edition::PRE_PUBLICATION_STATES.include?(state.to_s)
  end

  def edition_has_no_unpublished_editions
    return unless document

    if (existing_edition = document.non_published_edition)
      errors.add(:base, "There is already an active #{existing_edition.state} edition for this document")
    end
  end

  def has_workflow?
    true
  end

private

  def destroy_associations_with_edition_dependencies_and_dependants
    edition_dependencies.destroy_all
    records_of_dependent_editions.destroy_all
  end
end
