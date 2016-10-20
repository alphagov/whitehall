module PublishingApi
  module PayloadBuilder
    class TopicalEvents
      def self.for(item)
        { topical_events: TopicalEvent.for_edition(item.id).pluck(:content_id) }
      end
    end
  end
end
