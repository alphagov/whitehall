module ConfigurableAssociations
  class TopicalEvents
    def initialize(association)
      @association = association
    end

    def publishing_api_links_key
      :topical_events
    end

    def selected_ids
      @association.ids
    end

    def selected_content_ids
      @association.map(&:content_id)
    end

    def options_query
      TopicalEvent.order(:name)
    end

    def to_partial_path
      "admin/configurable_associations/topical_events"
    end
  end
end
