module PublishingApi
  module PayloadBuilder
    class MultipleParts
      attr_reader :item, :part_of

      def self.for(item, part_of)
        new(item, part_of).call
      end

      def initialize(item, part_of)
        @item = item
        @part_of = part_of
      end

      def call
        parts
      end

    private

      def parts
        item.type_instance.fields_for_part(part_of).map do |field|
          {
            field["part_name"].to_sym => item.block_content&.public_send(field["key"]),
          }
        end
      end
    end
  end
end
