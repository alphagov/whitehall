module ContentObjectStore
  module ContentBlock::Edition::Workflow
    extend ActiveSupport::Concern
    include DateValidation

    module ClassMethods
      def valid_state?(state)
        %w[draft published scheduled].include?(state)
      end
    end

    included do
      include ActiveRecord::Transitions

      date_attributes :scheduled_publication

      validates_with ContentObjectStore::ScheduledPublicationValidator

      state_machine auto_scopes: true do
        state :draft
        state :published
        state :scheduled

        event :publish do
          transitions from: %i[draft scheduled], to: :published
        end
        event :schedule do
          transitions from: %i[draft], to: :scheduled
        end
      end
    end
  end
end
