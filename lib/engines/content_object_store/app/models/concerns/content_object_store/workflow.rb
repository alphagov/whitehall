module ContentObjectStore::Workflow
  extend ActiveSupport::Concern

  module ClassMethods
    def valid_state?(state)
      %w[draft published].include?(state)
    end
  end

  included do
    include ActiveRecord::Transitions

    state_machine auto_scopes: true do
      state :draft
      state :published

      event :publish do
        transitions from: %i[draft], to: :published
      end
    end
  end
end
