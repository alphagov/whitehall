module PublishingApi
  module PayloadBuilder
    class BodyHeadings
      include Presenters::PublishingApi::PayloadHeadingsHelper

      attr_reader :item, :options

      def self.for(item, options = {})
        new(item, options).call
      end

      def initialize(item, options)
        @item = item
        @options = {
          auto_numbered_headers: options[:auto_numbered_headers] || false,
        }
      end

      def call
        extract_headings(item.body, options)
      end
    end
  end
end
