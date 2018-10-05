module PublishingApi
  module PayloadBuilder
    class FirstPublicAt
      def self.for(item)
        first_published_at = item.first_published_at

        return {} if first_published_at.nil?

        { first_public_at: first_published_at }
      end
    end
  end
end
