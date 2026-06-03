module PublishingApi
  module PayloadBuilder
    class MultipleParts
      attr_reader :item, :part_with_trailing_slash

      def self.for(item, part)
        new(item, part).call
      end

      def initialize(item, part_with_trailing_slash)
        @item = item
        @part_with_trailing_slash = part_with_trailing_slash 
      end

      def call
        parts
      end

    private

      def parts
        part = part_with_trailing_slash.gsub("/", "")
        hash = {
          slug: part,
        }
        item.type_instance.fields_for_part(part_with_trailing_slash).each_with_object(hash) do |field, obj|
          obj[field["key"].to_sym] = item.block_content&.public_send(part)[field["key"]]
        end
        hash
      end
    end
  end
end
