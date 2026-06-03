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
          details[attribute.to_sym] = if builder.is_a?(Array)
                                        builder.map do |part_builder|
                                          part_builder.each_with_object({}) do |(part_attribute, part_builder_type), part_details|
                                            if part_builder_type["hardcoded_value"]
                                              part_details[part_attribute.to_sym] = part_builder_type["hardcoded_value"]
                                            elsif part_builder_type["field"].include?(".")
                                              # TODO: again, support recursion for infinite depths
                                              namespace = part_builder_type["field"].split(".").first
                                              field = part_builder_type["field"].split(".").last
                                              part_details[part_attribute.to_sym] = send(part_builder_type["type"], item.block_content&.public_send(namespace)&.[](field))
                                            else
                                              part_details[part_attribute.to_sym] = send(part_builder_type["type"], item.block_content&.public_send(part_builder_type["field"]))
                                            end
                                          end
                                        end
                                      else
                                        send(builder["type"], item.block_content&.public_send(attribute))
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
    end
  end
end
