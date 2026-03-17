module PublishingApi
  module PayloadBuilder
    class Features
      include Presenters::PublishingApi::FeaturedDocumentsHelper

      attr_reader :item

      def self.for(item)
        new(item).call
      end

      def initialize(item)
        @item = item
      end

      def call
        { ordered_featured_documents: featured_documents(item, StandardEdition::FEATURED_DOCUMENTS_DISPLAY_LIMIT).map do |doc|
          doc[:summary] = ActionView::Base.full_sanitizer.sanitize(doc[:summary]).strip
          doc
        end }
      end
    end
  end
end
