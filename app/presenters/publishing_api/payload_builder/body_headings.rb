module PublishingApi
  module PayloadBuilder
    class BodyHeadings
      attr_reader :item

      def self.for(item)
        new(item).call
      end

      def initialize(item)
        @item = item
      end

      def call
        { headers: body_headings }
      end

    private

      def body_headings
        if item
          body_headings = Govspeak::Document.new(item.body).structured_headers
          remove_empty_headers(body_headings.map(&:to_h))
        else
          []
        end
      end

      def remove_empty_headers(body_headings)
        body_headings.each do |body_heading|
          body_heading.delete_if { |k, v| k == :headers && v.empty? }
          remove_empty_headers(body_heading[:headers]) if body_heading.key?(:headers)
        end
      end
    end
  end
end
