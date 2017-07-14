module Whitehall
  module GovUkDelivery
    class SubscriptionUrlGenerator
      def initialize(edition)
        @edition = edition
      end

      def subscription_urls
        [
          filter_urls,
          people_and_role_urls,
          topic_urls,
          topical_event_urls,
          world_location_urls,
          organisation_urls,
          url_maker.atom_feed_url(format: :atom)
        ].flatten.uniq
      end

    protected

      attr_reader :edition

      def url_maker
        Whitehall.url_maker
      end

      def relevant_to_local_government?
        edition.relevant_to_local_government?
      end

      def generate_urls(url_method, resources)
        resources.each_with_object([]) do |resource, urls|
          urls << url_method.call(resource, format: :atom, relevant_to_local_government: 1) if relevant_to_local_government?
          urls << url_method.call(resource, format: :atom)
        end
      end

      def url_helpers
        url_helpers_for_edition_type + url_helpers_for_global_feed
      end

      def url_helpers_for_edition_type
        case edition
        when Announcement
          url_helpers_for_announcements
        when Publicationesque
          if edition.included_in_statistics_feed?
            url_helpers_for_statistics
          else
            url_helpers_for_publications
          end
        else
          []
        end
      end

      def url_helpers_for_announcements
        [url_maker.method(:announcements_url)]
      end

      def url_helpers_for_statistics
        url_helpers_for_publications + [url_maker.method(:statistics_url)]
      end

      def url_helpers_for_publications
        [url_maker.method(:publications_url)]
      end

      def url_helpers_for_global_feed
        [url_maker.method(:atom_feed_url)]
      end

      def filter_option
        case edition
        when Announcement
          announcement_filter_options
        when Publicationesque
          publication_filter_options
        end
      end

      def announcement_filter_options
        {
          announcement_filter_option:
          Whitehall::AnnouncementFilterOption.find_by_search_format_types(edition.search_format_types).slug
        } if Whitehall::AnnouncementFilterOption.find_by_search_format_types(edition.search_format_types)
      end

      def publication_filter_options
        {
          publication_filter_option:
          Whitehall::PublicationFilterOption.find_by_search_format_types(edition.search_format_types).slug
        } if Whitehall::PublicationFilterOption.find_by_search_format_types(edition.search_format_types)
      end

      def topic_slugs
        edition.can_be_associated_with_topics? ? edition.topics.map(&:slug) : []
      end

      def topical_event_slugs
        edition.can_be_associated_with_topical_events? ? edition.topical_events.map(&:slug) : []
      end

      def department_slugs
        edition.respond_to?(:organisations) ? edition.organisations.map(&:slug) : []
      end

      def world_location_slugs
        edition.world_locations.map(&:slug)
      end

      def topic_urls
        generate_urls(url_maker.method(:topic_url), topic_slugs)
      end

      def topical_event_urls
        generate_urls(url_maker.method(:topical_event_url), topical_event_slugs)
      end

      def world_location_urls
        generate_urls(url_maker.method(:world_location_url), world_location_slugs)
      end

      def organisation_urls
        generate_urls(url_maker.method(:organisation_url), department_slugs)
      end

      def filter_urls
        filterable_slugs = [department_slugs, topic_slugs, world_location_slugs]
        slug_combinations = Product.for(filterable_slugs, default: nil)

        slug_combinations.map do |department_slug, topic_slug, location_slug|
          filters = {}

          filters[:departments] = [department_slug] if department_slug
          filters[:topics] = [topic_slug] if topic_slug
          filters[:world_locations] = [location_slug] if location_slug
          filters[:relevant_to_local_government] = 1 if relevant_to_local_government?
          filters.merge!(filter_option) if filter_option

          Powerset.for(filters).map do |params|
            url_helpers.map { |h| h.call(params.merge(format: :atom)) }
          end
        end
      end

      def people_and_role_urls
        appointments = []

        if edition.respond_to?(:role_appointments)
          appointments += edition.role_appointments
        end

        if edition.respond_to?(:role_appointment) && edition.role_appointment.present?
          appointments << edition.role_appointment
        end

        appointments.each_with_object([]) do |appointment, urls|
          urls << generate_urls(url_maker.method(:person_url), [appointment.person]) if appointment.person
          urls << generate_urls(url_maker.method(:ministerial_role_url), [appointment.role]) if appointment.role
        end
      end

      # https://en.wikipedia.org/wiki/Cartesian_product
      module Product
        def self.for(arrays, options = {})
          if options.key?(:default)
            default = options.fetch(:default)
            arrays = arrays.map { |arr| arr.empty? ? [default] : arr }
          end

          arrays.first.product(*arrays.drop(1))
        end
      end

      # https://en.wikipedia.org/wiki/Power_set
      module Powerset
        def self.for(collection)
          array = collection.to_a

          powerset = 0.upto(array.size).flat_map do |n|
            array.combination(n).to_a
          end

          if collection.is_a?(Hash)
            powerset.map(&:to_h)
          else
            powerset
          end
        end
      end
    end
  end
end
