module PublishingApi
  module PayloadBuilder
    class AccessLimitation
      def self.for(item)
        return {} unless item.access_limited? && !item.publicly_visible?

        { access_limited: { organisations: item.organisations.pluck(:content_id).compact } }
      end
    end
  end
end
