module ConfigurableAssociations
  class TopicalEvents
    def initialize(association)
      @association = association
    end

    def links
      {
        topical_events: @association.map(&:content_id),
      }
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
