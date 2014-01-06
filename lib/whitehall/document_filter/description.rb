require 'whitehall/document_filter/options'
require 'uri'
require 'cgi'

module Whitehall
  module DocumentFilter
    class Description

      def initialize(feed_url)
        @feed_url = feed_url
        query = URI.parse(feed_url).query
        @params = CGI.parse(query) if query
        @options_manager = DocumentFilter::Options.new
      end

      def text
        if @feed_url =~ %r{(policies|ministers|people)/([a-z-]+)}
          type = $1
          slug = $2

          klass = classify_type(type)

          if klass == Policy
            if policy = Document.where(slug: slug, document_type: 'Policy').first
              policy.published_edition.try(:title)
            end
          else
            klass.find_by_slug(slug).try(:name)
          end
        else
          labels_from_params.join(', ')
        end
      end

    protected

      def classify_type(type)
        case type
        when 'policies'
          Policy
        when 'ministers'
          Role
        when 'people'
          Person
        end
      end

      def labels_from_params
        @params.flat_map do |key, values|
          Array(values).map do |value|
            @options_manager.sentence_fragment_for(key, value)
          end
        end.compact
      end
    end
  end
end
