module PublishingApi
  module PayloadBuilder
    class FirstPublishedAt
      def self.for(item)
        first_published_at = item.first_published_at

        return {} if first_published_at.nil?

        { first_published_at: first_published_at }
      end
    end
  end
end
