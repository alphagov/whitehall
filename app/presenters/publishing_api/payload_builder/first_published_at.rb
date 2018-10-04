module PublishingApi
  module PayloadBuilder
    class FirstPublishedAt
      def self.for(item)
        if item.document.published?
          { first_published_at: item.document.first_published_date }
        else
          {}
        end
      end
    end
  end
end
