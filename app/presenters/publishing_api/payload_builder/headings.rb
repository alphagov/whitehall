module PublishingApi
  module PayloadBuilder
    class Headings
      include Presenters::PublishingApi::PayloadHeadingsHelper

      attr_reader :govspeak, :options

      def self.for(govspeak, options = {})
        new(govspeak, options).call
      end

      def initialize(govspeak, options)
        @govspeak = govspeak
        @options = {
          auto_numbered_headers: options[:auto_numbered_headers] || false,
          auto_numbered_header_levels: [2, 3],
        }
      end

      def call
        extract_headings(govspeak, options)
      end
    end
  end
end
