module PublishingApi
  module PayloadBuilder
    class FirstPublicAt
      def self.for(item)
        if item.document.published?
          { first_public_at: item.document.first_published_date || item.document.created_at }
        else
          {}
        end
      end
    end
  end
end
