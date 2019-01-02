module PublishingApi
  module PayloadBuilder
    class TagDetails
      attr_reader :item

      def self.for(item)
        new(item).call
      end

      def initialize(item)
        @item = item
      end

      def call
        {
          # These tags are used downstream for sending email alerts.
          # For more details please see
          # https://gov-uk.atlassian.net/wiki/display/TECH/Email+alerts+2.0
          tags: {
            browse_pages: [],
            policies: policies,
            topics: specialist_sectors,
          }
        }
      end

    private

      def policies
        return [] unless item.can_be_related_to_policies?

        item.policies.map(&:slug)
      end

      def specialist_sectors
        [item.primary_specialist_sector_tag].compact + item.secondary_specialist_sector_tags
      end
    end
  end
end
