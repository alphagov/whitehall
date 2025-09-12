module ConfigurableAssociations
  class WorldLocations
    def initialize(association, errors)
      @association = association
      @errors = errors
    end

    attr_reader :errors

    def publishing_api_links_key
      :world_locations
    end

    def selected_ids
      @association.ids
    end

    def selected_content_ids
      @association.map(&:content_id)
    end

    def options_query
      WorldLocation.ordered_by_name.where(active: true)
    end

    def to_partial_path
      "admin/configurable_associations/world_locations"
    end
  end
end
