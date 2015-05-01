require 'whitehall/document_filter/options'
require 'uri'
require 'cgi'

module Whitehall
  module GovUkDelivery
    class FeedUrlValidator
      attr_reader :feed_url, :feed_type, :feed_object_slug, :filter_options_describer

      def initialize(feed_url)
        @feed_url = feed_url
        @filter_options_describer = DocumentFilter::Options.new
        parse_feed_url if uri && recognised_url?
      end

      def description
        if valid?
          [leading_fragment, parameter_fragments, command_and_act_fragment, relevant_to_local_government_fragment].compact.join " "
        end
      end

      def valid?
        uri &&
        recognised_url? &&
        recognised_feed_type? &&
        resource_exists? &&
        filter_parameters_are_valid?
      end

      def feed_params
        @feed_params ||= Rack::Utils.parse_nested_query(uri.query)
      end

      def filtered_documents_feed?
        %w(publications announcements statistics).include?(feed_type)
      end

    protected

      def valid_host_and_protocol?
        uri.host == Whitehall.public_host && uri.scheme == Whitehall.public_protocol
      end

      def recognised_url?
        valid_host_and_protocol? && recognised_path? && valid_extension?
      end

      def recognised_path?
        Rails.application.routes.recognize_path(uri.path)
      rescue ActionController::RoutingError
        false
      end

      def recognised_feed_type?
        !!feed_type
      end

      def valid_extension?
        File.extname(uri.path) == '.atom'
      end

      def resource_exists?
        leading_fragment.present?
      end

      def filter_parameters_are_valid?
        if filtered_documents_feed?
          filter_param_keys_valid? && filter_param_resources_exist?
        else
          feed_params.except('relevant_to_local_government').none?
        end
      end

      def filter_param_keys_valid?
        filter_options_describer.valid_keys?(feed_params.keys)
      end

      def filter_param_resources_exist?
        filter_options_describer.valid_resource_filter_options?(resource_filter_params)
      end

      def uri
        @uri ||= begin
          URI.parse(feed_url)
        rescue URI::InvalidURIError
          nil
        end
      end

      def parse_feed_url
        if uri.path == url_maker.publications_path
          @feed_type = 'publications'
        elsif uri.path == url_maker.announcements_path
          @feed_type = 'announcements'
        elsif uri.path == url_maker.statistics_path
          @feed_type = 'publications'
        else
          path_root_fragment = uri.path.split('/')[2];
          @feed_object_slug = uri.path.match(/([^\/]*)\.atom$/)[1]

          case path_root_fragment
          when "policies"
            @feed_object_slug = uri.path.match(/([^\/]*)\/activity\.atom$/)[1]
            @feed_type = 'policy'
          when 'organisations'
            @feed_type = 'organisation'
          when 'topics'
            @feed_type = 'topic'
          when 'topical-events'
            @feed_type = 'topical_event'
          when 'world'
            @feed_type = 'world_location'
          when 'people'
            @feed_type = 'person'
          when 'ministers'
            @feed_type = 'role'
          end
        end
      end

      def leading_fragment
        if feed_params['publication_filter_option'].present?
          fragment_for_filter_option('publication_filter_option').downcase
        elsif feed_params['announcement_filter_option'].present?
          fragment_for_filter_option('announcement_filter_option').downcase
        elsif ['publications', 'announcements'].include? feed_type
          feed_type
        else
          label_for_resource
        end
      end

      def resource_filter_params
        feed_params.except(*%w(publication_filter_option announcement_filter_option official_document_status relevant_to_local_government))
      end

      def parameter_fragments
        if resource_filter_params.any?
          "related to " + (resource_filter_params.map { |param_key, _|
            fragment_for_filter_option(param_key)
          }.to_sentence)
        else
          nil
        end
      end

      def command_and_act_fragment
        if feed_params['official_document_status'].present?
          case feed_params['official_document_status']
          when "command_and_act_papers"
            "which are command or act papers"
          when "command_papers_only"
            "which are command papers"
          when "act_papers_only"
            "which are act papers"
          end
        end
      end

      def relevant_to_local_government_fragment
        relevant_to_local_government = feed_params['relevant_to_local_government'] && feed_params['relevant_to_local_government'] != "0"
        if relevant_to_local_government && feed_params['official_document_status'].present?
          "and are relevant to local government"
        elsif relevant_to_local_government
          "which are relevant to local government"
        else
          nil
        end
      end

      def fragment_for_filter_option(param_key)
        labels_for_filter_option(param_key).join(", ")
      end

      def labels_for_filter_option(param_key)
        param_values = Array(feed_params[param_key])
        param_values.map { |value|
          filter_options_describer.label_for(param_key, value)
        }
      end

      def label_for_resource
        if resource_class < Edition
          if document = Document.find_by(slug: feed_object_slug)
            document.published_edition.try(:title)
          end
        else
          resource_class.find_by(slug: feed_object_slug).try(:name)
        end
      end

      def resource_class
        if !['organisation', 'policy', 'topic', 'topical_event', 'person', 'role', 'world_location'].include? feed_type
          raise ArgumentError.new("Can't process a feed for unknown type '#{feed_type}'")
        end
        Kernel.const_get feed_type.camelize
      end

      def url_maker
        @url_maker ||= UrlMaker.new(format: :atom)
      end
    end
  end
end
