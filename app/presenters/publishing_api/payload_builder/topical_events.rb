module PublishingApi
  module PayloadBuilder
    class TopicalEvents
      def self.for(item)
        { topical_events: item.topical_events.pluck(:content_id) + item.topical_event_documents.pluck(:content_id) }
      end
    end
  end
end
