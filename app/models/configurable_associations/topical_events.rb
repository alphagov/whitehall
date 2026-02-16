module ConfigurableAssociations
  class TopicalEvents
    def initialize(association)
      @association = association
    end

    def selected_ids
      @association.ids
    end

    def options_query
      TopicalEvent.order(:name)
    end

    def to_partial_path
      "admin/configurable_associations/topical_events"
    end
  end
end
