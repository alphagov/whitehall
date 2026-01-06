module PublishingApi
  module PayloadBuilder
    class BodyHeadings
      include Presenters::PublishingApi::PayloadHeadingsHelper

      attr_reader :item, :options, additional_html

      def self.for(item, options = {}, additional_html = nil)
        new(item, options, additional_html).call
      end

      def initialize(item, options)
        @item = item
        @options = {
          auto_numbered_headers: options[:auto_numbered_headers] || false,
          auto_numbered_header_levels: [2, 3],
        }
      end

      def call
        additional_html.present? ? extract_headings(additional_html, options) : extract_headings(item.body, options)
      end
    end
  end
end
