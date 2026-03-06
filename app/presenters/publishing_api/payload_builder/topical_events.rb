module PublishingApi
  module PayloadBuilder
    class TopicalEvents
      def self.for(item)
        config_driven_topical_events = item.topical_event_documents.pluck(:content_id)
        {
          topical_events: config_driven_topical_events,
        }
      end
    end
  end
end
