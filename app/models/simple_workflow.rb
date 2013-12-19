# Expects Searchable to be included and destroyable? defined.
module SimpleWorkflow
  extend ActiveSupport::Concern

  included do
    include ActiveRecord::Transitions

    default_scope -> { where(arel_table[:state].not_eq("deleted")) }

    state_machine auto_scopes: true, initial: :current do
      state :current
      state :deleted

      event :delete, success: -> document { document.remove_from_search_index if document.respond_to?(:remove_from_search_index) } do
        transitions from: [:current], to: :deleted, guard: :destroyable?
      end
    end

    #Overwrite this
    def destroyable?
      true
    end
  end
end