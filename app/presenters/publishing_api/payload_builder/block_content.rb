module PublishingApi
  module PayloadBuilder
    class BlockContent
      include GovspeakHelper

      def self.for(item)
        new(item).call
      end

      def initialize(item)
        @item = item
      end

      def call
        mapping = @item.type_instance.presenter("publishing_api")["details"]
        return {} unless mapping

        mapping.each_with_object({}) { |(attribute, builder), details|
          details[attribute.to_sym] = send(builder, attribute)
        }.compact
      end

    private

      attr_reader :item

      def raw(attribute)
        item.block_content&.public_send(attribute)
      end

      def govspeak(attribute)
        content = item.block_content&.public_send(attribute)
        return nil if content.nil?

        govspeak_to_html(content, images: item.images, attachments: item.attachments)
      end

      def rfc3339_date(attribute)
        item.block_content&.public_send(attribute)&.rfc3339
      end

      def social_media_links(attribute)
        content = item.block_content&.public_send(attribute)
        return [] if content.blank?

        content.map do |item|
          # `item` looks something like `{"url"=>"foo", "social_media_service_name"=>"Facebook"}`
          service_name = item["social_media_service_name"]
          service_url = item["url"]
          {
            title: service_name,
            service_type: service_name.parameterize, # "Google Plus" => "google-plus"
            href: service_url,
          }
        end
      end
    end
  end
end
