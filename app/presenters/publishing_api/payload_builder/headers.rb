module PublishingApi
  module PayloadBuilder
    class Headers
      attr_reader :item

      def self.for(item)
        new(item).call
      end

      def initialize(item)
        @item = item
      end

      def call
        { headers: }
      end

    private

      def headers
        if item
          headers = Govspeak::Document.new(item.body).structured_headers
          remove_empty_headers(headers.map(&:to_h))
        else
          []
        end
      end

      def remove_empty_headers(headers)
        headers.each do |header|
          header.delete_if { |k, v| k == :headers && v.empty? }
          remove_empty_headers(header[:headers]) if header.key?(:headers)
        end
      end
    end
  end
end
