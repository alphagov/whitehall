module PublishingApi
  module PayloadBuilder
    class BlockContent
      include GovspeakHelper
      include Presenters::PublishingApi::PayloadHeadingsHelper

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
          if builder["type"]
            details[attribute.to_sym] = send(builder["type"], item.block_content&.public_send(attribute))
          else # this is a nested hash
            # TODO: again, we want to support recursion for infinite depths
            # And probably handle possible namespace clash of field/type/hardcoded_value keys better
            child_hash = {}
            builder.keys.each do |part_attribute|
              part_builder_type = builder[part_attribute]
              if part_builder_type["hardcoded_value"]
                child_hash[part_attribute.to_sym] = part_builder_type["hardcoded_value"]
              elsif part_builder_type["field"].include?(".")
                namespace = part_builder_type["field"].split(".").first
                field = part_builder_type["field"].split(".").last
                child_hash[part_attribute.to_sym] = send(part_builder_type["type"], item.block_content&.public_send(namespace)&.[](field))
              else
                child_hash[part_attribute.to_sym] = send(part_builder_type["type"], item.block_content&.public_send(part_builder_type["field"]))
              end
            end
            details[attribute.to_sym] = child_hash
          end
        }.compact
      end

    private

      attr_reader :item

      def raw(attribute)
        attribute
      end

      def compiled_govspeak(content)
        return nil if content.nil?

        govspeak_to_html(content, images: item.images, attachments: item.attachments)
      end

      def compiled_and_raw_govspeak(content)
        return nil if content.nil?

        [
          {
            content_type: "text/html",
            content: compiled_govspeak(content),
          },
          {
            content_type: "text/govspeak",
            content: content,
          },
        ]
      end

      def rfc3339_date(attribute)
        attribute&.rfc3339
      end

      def social_media_links(content)
        return [] if content.blank?

        content.map do |item|
          # `item` looks something like `{"url"=>"foo", "social_media_service_name"=>"Facebook", "title"=> "Optional title"}`
          service_name = item["social_media_service_name"]
          service_url = item["url"]
          title = item["title"]
          {
            title: title.presence || service_name,
            service_type: service_name.parameterize, # "Google Plus" => "google-plus"
            href: service_url,
          }
        end
      end

      def headings_from(attribute)
        return nil if attribute.nil?

        extract_headings(attribute)[:headers]
      end
    end
  end
end
