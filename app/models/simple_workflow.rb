# Expect Searchable to be included and destroyable? defined.
module SimpleWorkflow
  extend ActiveSupport::Concern

  included do
    include ActiveRecord::Transitions

    default_scope where(arel_table[:state].not_eq("deleted"))

    state_machine do
      state :current
      state :deleted

      event :delete, success: -> document { document.remove_from_search_index } do
        transitions from: [:current], to: :deleted, guard: :destroyable?
      end
    end
  end
end