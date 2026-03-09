# Config-driven content types present their 'topical event' associations via the
# `ConfigurableDocumentLinks` payload builder. When all content types have been
# migrated to being config-driven, we'll be able to delete this module. For now,
# it's the only means through which 'legacy' content types can present their
# 'config-driven topical event' associations.
module PublishingApi
  module PayloadBuilder
    class TopicalEvents
      def self.for(item)
        legacy_topical_events = item.topical_events.pluck(:content_id)
        config_driven_topical_events = item.topical_event_documents.pluck(:content_id)
        {
          topical_events: legacy_topical_events + config_driven_topical_events,
        }
      end
    end
  end
end
