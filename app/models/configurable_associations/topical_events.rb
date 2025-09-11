module ConfigurableAssociations
  class TopicalEvents
    def initialize(config, association)
      @config = config
      @association = association
    end

    def selected_ids
      @association.pluck(:id)
    end

    def to_partial_path
      "admin/configurable_associations/topical_events"
    end
  end
end
