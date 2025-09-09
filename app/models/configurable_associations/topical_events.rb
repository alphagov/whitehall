module ConfigurableAssociations
  class TopicalEvents
    delegate :topical_event_ids, to: :@edition
    def initialize(config, edition)
      @config = config
      @edition = edition
    end

    def label
      @config["label"]
    end

    def to_partial_path
      "admin/configurable_associations/topical_events"
    end
  end
end
