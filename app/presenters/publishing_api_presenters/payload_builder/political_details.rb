module PublishingApiPresenters
  module PayloadBuilder
    class PoliticalDetails
      attr_reader :item

      def self.for(item)
        new(item).for
      end

      def initialize(item)
        @item = item
      end

      def for
        {
          political: item.political?,
          government: government
        }
      end

    private

      def government
        gov = item.government
        return nil unless gov
        {
          title: gov.name,
          slug: gov.slug,
          current: gov.current?
        }
      end
    end
  end
end
