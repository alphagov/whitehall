module Whitehall
  module GovUkDelivery
    class SubscriptionUrlGenerator
      def initialize(edition)
        @edition = edition
      end

      def subscription_urls
        urls = []
        urls += filter_urls
        urls += policy_urls
        urls += people_and_role_urls
        urls += topic_urls
        urls += topical_event_urls

        # Fallback URL including everything
        urls << url_maker.atom_feed_url(format: :atom)

        urls.flatten.uniq
      end

    protected

      attr_reader :edition

      def url_maker
        @url_maker ||= Whitehall::UrlMaker.new(host: Whitehall.public_host, protocol: Whitehall.public_protocol)
      end

      def url_helper(edition, args={})
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
          {
            announcement_filter_option:
            Whitehall::AnnouncementFilterOption.find_by_search_format_types(edition.search_format_types).slug
          } if Whitehall::AnnouncementFilterOption.find_by_search_format_types(edition.search_format_types)
        when Publicationesque
          {
            publication_filter_option:
            Whitehall::PublicationFilterOption.find_by_search_format_types(edition.search_format_types).slug
          } if Whitehall::PublicationFilterOption.find_by_search_format_types(edition.search_format_types)
        end
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
        if edition.can_be_associated_with_topics?
          topic_slugs = edition.topics.map(&:slug)
        else
          topic_slugs = []
        end
      end

      def topical_event_slugs
        if edition.can_be_associated_with_topical_events?
          topical_event_slugs = edition.topical_events.map(&:slug)
        else
          topical_event_slugs = []
        end
      end

      def department_slugs
        edition.organisations.map(&:slug)
      end

      def topic_urls
        topic_slugs.map do |slug|
          url_maker.topic_url(slug, format: :atom)
        end
      end

      def topical_event_urls
        topical_event_slugs.map do |slug|
          url_maker.topical_event_url(slug, format: :atom)
        end
      end

      def filter_urls
        department_and_topic_combos = [department_slugs, topic_slugs].inject(&:product)
        department_and_topic_combos.map do |(org, topic)|
          combinatorial_args = [{departments: [org]}, {topics: [topic]}]
          combinatorial_args << filter_option if filter_option
          combinatorial_args << { relevant_to_local_government: 1 } if edition.relevant_to_local_government?

          all_combinations_of_args(combinatorial_args).map do |combined_args|
            [
              url_helper(edition, combined_args),
              url_maker.atom_feed_url(combined_args.merge(format: :atom))
            ]
          end
        end
      end

      def policy_urls
        if edition.can_be_related_to_policies?
          edition.published_related_policies.map do |policy|
            url_maker.activity_policy_url(policy.document, format: :atom)
          end
        else
          []
        end
      end

      def people_and_role_urls
        urls = []

        if edition.can_be_associated_with_role_appointments?
          edition.role_appointments.each do |appointment|
            urls << url_maker.polymorphic_url(appointment.person, format: 'atom') if appointment.person
            urls << url_maker.polymorphic_url(appointment.role, format: 'atom') if appointment.role
          end
        end

        return urls
      end
    end
  end
end
