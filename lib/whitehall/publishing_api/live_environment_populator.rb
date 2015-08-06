module Whitehall
  class PublishingApi
    class LiveEnvironmentPopulator < Populator
      def initialize(items: nil, logger:)
        super(
          items: items || self.class.default_items,
          sender: self.class.method(:send_to_publishing_api),
          logger: logger
        )
      end

      def self.send_to_publishing_api(item)
        update_type = 'bulk_update'
        queue_name = 'bulk_republishing'
        PublishingApi.publish_async(item, update_type, queue_name)
      end

      def self.edition_scope
        Edition.latest_published_edition
      end
    end
  end
end
