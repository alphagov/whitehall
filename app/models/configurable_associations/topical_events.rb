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

    def template_cache_digest
      topical_event_timestamps = options_query.pluck(:updated_at)
      update_timestamps = topical_event_timestamps.map(&:to_i).join
      Digest::MD5.hexdigest "topical-events-#{update_timestamps}"
    end

    def to_partial_path
      "admin/configurable_associations/topical_events"
    end
  end
end
