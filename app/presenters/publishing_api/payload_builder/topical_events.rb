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
