module Whitehall
  module GovUkDelivery
    class SubscriptionUrlGenerator
      def initialize(edition)
        @edition = edition
      end

      def subscription_urls
        [
          filter_urls,
          policy_urls,
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
        @url_maker ||= Whitehall::UrlMaker.new(host: Whitehall.public_host, protocol: Whitehall.public_protocol)
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

      def edition_url(args={})
        url_params = args.merge(format: :atom)

        case edition
        when Policy
          url_maker.policies_url(url_params)
        when Announcement
          url_maker.announcements_url(url_params)
        when Publicationesque
          url_maker.publications_url(url_params)
        end
      end

      def filter_option
        case edition
        when Policy
          nil
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

      def all_combinations_of_args(args)
        # turn [1,2,3] into [[], [1], [2], [3], [1,2], [1,3], [2,3], [1,2,3]]
        # then, given 1 is really {a: 1} and 2 is {b: 2} etc...
        # turn that into [{}, {a:1}, {b: 2}, {c: 3}, {a:1, b:2}, {a:1, c:3}, ...]
        0.upto(args.size)
          .map { |s| args.combination(s) }
          .flat_map(&:to_a)
          .map { |c| c.inject({}) { |h, a| h.merge(a) } }
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
        department_and_topic_combos = [department_slugs, topic_slugs].inject(&:product)
        department_and_topic_combos.map do |(org, topic)|
          combinatorial_args = [{departments: [org]}, {topics: [topic]}]
          combinatorial_args << filter_option if filter_option
          combinatorial_args << { relevant_to_local_government: 1 } if relevant_to_local_government?

          all_combinations_of_args(combinatorial_args).map do |combined_args|
            [
              edition_url(combined_args),
              url_maker.atom_feed_url(combined_args.merge(format: :atom))
            ]
          end
        end
      end

      def policy_urls
        if edition.can_be_related_to_policies?
          generate_urls(url_maker.method(:activity_policy_url), edition.published_related_policies.map(&:document))
        else
          []
        end
      end

      def people_and_role_urls
        appointments = []

        if edition.respond_to?(:role_appointments)
          appointments += edition.role_appointments
        end

        if edition.respond_to?(:role_appointment)
          appointments << edition.role_appointment
        end

        appointments.each_with_object([]) do |appointment, urls|
          urls << generate_urls(url_maker.method(:person_url), [appointment.person]) if appointment.person
          urls << generate_urls(url_maker.method(:ministerial_role_url), [appointment.role]) if appointment.role
        end
      end
    end
  end
end
