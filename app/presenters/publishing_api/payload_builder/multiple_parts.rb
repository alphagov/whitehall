module PublishingApi
  module PayloadBuilder
    class MultipleParts
      attr_reader :item, :part

      def self.for(item, part)
        new(item, part).call
      end

      def initialize(item, part)
        @item = item
        @part = part
      end

      def call
        parts
      end

    private

      def parts
        hash = {
          slug: part.gsub("/", ""),
        }
        item.type_instance.fields_for_part(part).each_with_object(hash) do |field, obj|
          obj[field["part_name"].to_sym] = item.block_content&.public_send(field["key"])
        end
        hash
      end
    end
  end
end
