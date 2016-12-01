module PublishingApi
  module PayloadBuilder
    class FirstPublicAt
      def self.for(item)
        { first_public_at: FirstPublishedAt.for(item)[:first_published_at] }
      end
    end
  end
end
