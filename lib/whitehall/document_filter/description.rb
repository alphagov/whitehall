require 'whitehall/document_filter/options'
require 'uri'
require 'cgi'

module Whitehall
  module DocumentFilter
    class Description

      def initialize(feed_url)
        query = URI.parse(feed_url).query
        @params = CGI.parse(query) if query
        @options_manager = DocumentFilter::Options.new
      end

      def text
        return '' if @params.nil?

        @params.flat_map do |key, values|
          Array(values).map do |value|
            label_for(key, value)
          end
        end.compact.join(', ')
      end

    protected

      def label_for(key, value)
        label = @options_manager.label_for(key, value)

        @options_manager.proper_noun?(key, value) ? label : label.try(:downcase)
      end

    end
  end
end
