require 'whitehall/document_filter/options'
require 'uri'
require 'cgi'

module Whitehall
  module DocumentFilter
    class Description
      attr_reader :feed_type, :feed_params, :feed_object_slug, :filter_options_describer

      def initialize(feed_url)
        feed_url = URI.parse feed_url
        @feed_params =  Rack::Utils.parse_nested_query(feed_url.query).symbolize_keys
        @filter_options_describer = DocumentFilter::Options.new

        if feed_url.path == url_maker.atom_feed_path
          @feed_type = 'documents'
        elsif feed_url.path == url_maker.publications_path
          @feed_type = 'publications'
        elsif feed_url.path == url_maker.announcements_path
          @feed_type = 'announcements'
        else
          @feed_object_slug = feed_url.path.match(/([^\/]*)\.atom$/)[1]
          if feed_url.path == url_maker.organisation_path(@feed_object_slug)
            @feed_type = 'organisation'
          elsif feed_url.path == url_maker.policy_path(@feed_object_slug)
            @feed_type = 'policy'
          elsif feed_url.path == url_maker.topic_path(@feed_object_slug)
            @feed_type = 'topic'
          elsif feed_url.path == url_maker.topical_event_path(@feed_object_slug)
            @feed_type = 'topical_event'
          elsif feed_url.path == url_maker.world_location_path(@feed_object_slug)
            @feed_type = 'world_location'
          elsif feed_url.path == url_maker.person_path(@feed_object_slug)
            @feed_type = 'person'
          elsif feed_url.path == url_maker.ministerial_role_path(@feed_object_slug)
            @feed_type = 'role'
          end
        end
      end

      def text
        [leading_fragment, parameter_fragments, command_and_act_fragment].compact.join " "
      end

    protected

      def leading_fragment
        if feed_params[:publication_filter_option].present?
          label_for_param(:publication_filter_option).downcase
        elsif feed_params[:announcement_filter_option].present?
          label_for_param(:announcement_filter_option).downcase
        elsif ['documents', 'publications', 'announcements'].include? feed_type
          feed_type
        else
          label_from_slug(type: feed_type, slug: feed_object_slug)
        end
      end

      def parameter_fragments
        listable_params = feed_params.except(:publication_filter_option, :announcement_filter_option, :official_document_status)
        if listable_params.any?
          "related to " + (listable_params.map { |param_key, _|
            label_for_param(param_key)
          }.to_sentence)
        else
          nil
        end
      end

      def command_and_act_fragment
        if feed_params[:official_document_status].present?
          case feed_params[:official_document_status]
          when "command_and_act_papers"
            "which are command or act papers"
          when "command_papers_only"
            "which are command papers"
          when "act_papers_only"
            "which are act papers"
          end
        end
      end

      def label_for_param(param_key)
        param_values = Array(feed_params[param_key])
        param_values.map { |value|
          filter_options_describer.label_for(param_key.to_s, value)
        }.join ", "
      end

      def label_from_slug(type: nil, slug: nil)
        klass = classify_type(type)
        if klass < Edition
          Document.find_by_slug(@feed_object_slug).published_edition.title
        else
          klass.find_by_slug(slug).try(:name)
        end
      end

      def classify_type(type)
        if !['organisation', 'policy', 'topic', 'topical_event', 'person', 'role', 'world_location'].include? type
          raise ArgumentError.new("Can't process a feed for unknown type '#{type}'")
        end
        Kernel.const_get type.camelize
      end

      def url_maker
        @url_maker ||= UrlMaker.new(format: :atom)
      end
    end
  end
end
