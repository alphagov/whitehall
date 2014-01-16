require 'whitehall/document_filter/options'
require 'uri'
require 'cgi'

module Whitehall
  module DocumentFilter
    class Description

      def initialize(feed_url, default_params = {})
        @feed_url = feed_url

        unless feed_url.blank?
          query = URI.parse(feed_url).query
          feed_params = Rack::Utils.parse_nested_query(query)
          @params = default_params.merge(feed_params)
          @options_manager = DocumentFilter::Options.new
        end
      end

      def text
        return '' if @feed_url.blank?

        if @feed_url =~ %r{(policies|ministers|people)/([\w-]+)}
          label_from_slug(type: $1, slug: $2)
        else
          labels_from_params.join(', ')
        end
      end

    protected

      def labels_from_params
        @params.flat_map do |key, values|
          Array(values).map do |value|
            @options_manager.sentence_fragment_for(key, value)
          end
        end.compact
      end

      def label_from_slug(type: nil, slug: nil)
        klass = classify_type(type)

        if klass == Policy
          if policy = Document.where(slug: slug, document_type: 'Policy').first
            policy.published_edition.try(:title)
          end
        else
          klass.find_by_slug(slug).try(:name)
        end
      end

      def classify_type(type)
        case type
        when 'policies'
          Policy
        when 'ministers'
          Role
        when 'people'
          Person
        else
          raise ArgumentError.new("Can't process a feed for unknown type '#{type}'")
        end
      end
    end
  end
end
