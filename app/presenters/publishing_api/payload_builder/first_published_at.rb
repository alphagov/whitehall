module PublishingApi
  module PayloadBuilder
    class FirstPublishedAt
      def self.for(item)
        { first_published_at: item.first_published_at || item.document.created_at }
      end
    end
  end
end
