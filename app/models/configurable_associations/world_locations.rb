module ConfigurableAssociations
  class WorldLocations
    attr_reader :errors, :required

    def initialize(association, errors, required: false)
      @association = association
      @errors = errors
      @required = required
    end

    def links
      {
        world_locations: @association.map(&:content_id),
      }
    end

    def selected_ids
      @association.ids
    end

    def options_query
      WorldLocation.ordered_by_name.where(active: true)
    end

    def to_partial_path
      "admin/configurable_associations/world_locations"
    end
  end
end
