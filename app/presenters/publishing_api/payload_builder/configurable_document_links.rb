module PublishingApi::PayloadBuilder
  class ConfigurableDocumentLinks
    def self.for(item)
      association_links(item).merge(government_links(item))
    end

    def self.association_links(item)
      factory = ConfigurableAssociations::Factory.new(item)
      factory.configurable_associations.map(&:links).reduce({}, :merge)
    end

    def self.government_links(item)
      return {} unless item.type_instance.settings["history_mode_enabled"]

      { government: [item.government&.content_id].compact }
    end
  end
end
