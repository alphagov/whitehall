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
          # `item` looks something like `{"url"=>"foo", "social_media_service_name"=>"Facebook", "title"=> "Optional title"}`
          service_name = item["social_media_service_name"]
          service_url = item["url"]

          title = if item["title"].present?
                    item["title"]
                  elsif service_name.parameterize == "x"
                    "Follow us on X"
                  else
                    service_name
                  end

          {
            title: title,
            service_type: service_name.parameterize, # "Google Plus" => "google-plus"
            href: service_url,
          }
        end
      end

      def national_applicability(_attribute)
        entries = NationApplicability.cast(item.block_content&.nation_applicability)
        return nil if entries.empty?

        excluded_nations = entries.index_by { |entry| entry["nation"] }

        Nation.potentially_inapplicable.each_with_object({}) do |nation, payload|
          key = nation.name.tr(" ", "_").downcase
          exclusion = excluded_nations[key]
          payload[key.to_sym] = { label: nation.name, applicable: exclusion.nil? }
          payload[key.to_sym][:alternative_url] = exclusion["alternative_url"].to_s if exclusion
        end
      end
    end
  end
end
