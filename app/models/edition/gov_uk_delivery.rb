# encoding: utf-8
require 'uri'
require 'erb'

require 'gds_api/exceptions'

module Edition::GovUkDelivery
  extend ActiveSupport::Concern

  included do
    set_callback(:publish, :after) { Notifier.new(self).edition_published! }
  end

  class Notifier
    attr_accessor :edition
    def initialize(edition)
      @edition = edition
    end

    def edition_published!
      if edition_can_be_sent_as_notification?
        if edition.relevant_to_local_government?
          notify_email_curation_queue
        else
          notify_govuk_delivery
        end
      end
    end

    def notify_email_curation_queue
      EmailCurationQueue.new(edition, notification_date).notify!
    end

    def notify_govuk_delivery
      GovUkDelivery.new(edition, notification_date).notify!
    end

    def edition_can_be_sent_as_notification?
      !edition.minor_change? &&
        # We don't want to send anything that will appear to have been
        # published in the past.
        (Time.zone.now.to_date == notification_date.to_date) &&
        edition.available_in_locale?(:en)
    end

    def notification_date
      if edition.is_a? Speech
        edition.major_change_published_at
      else
        edition.public_timestamp
      end
    end

    class NotificationEndPoint < Struct.new(:edition, :notification_date)
    end

    class EmailCurationQueue < NotificationEndPoint
      def notify!
        EmailCurationQueueItem.create_from_edition(edition, notification_date)
      end
    end

    class GovUkDelivery < NotificationEndPoint
      include Rails.application.routes.url_helpers
      include PublicDocumentRoutesHelper

      attr_reader :title, :summary
      def initialize(edition, notification_date, title = edition.title, summary = edition.summary)
        super(edition, notification_date)
        @title = title
        @summary = summary
      end

      def self.notify_from_queue!(email_curation_queue_item)
        new(email_curation_queue_item.edition,
            email_curation_queue_item.notification_date,
            email_curation_queue_item.title,
            email_curation_queue_item.summary).notify!
      end

      def govuk_delivery_tags
        if edition.can_be_associated_with_topics? || edition.can_be_related_to_policies?
          topic_slugs = edition.topics.map(&:slug)
        else
          topic_slugs = []
        end

        org_slugs = edition.organisations.map(&:slug)

        tags = [org_slugs, topic_slugs].inject(&:product)

        required_url_args = { format: :atom, host: Whitehall.public_host, protocol: Whitehall.public_protocol }
        required_url_args[:relevant_to_local_government] = 1 if edition.relevant_to_local_government?
        tag_paths = tags.map do |t|
          combinatorial_args = [{departments: [t[0]]}, {topics: [t[1]]}]
          case edition
          when Policy
            all_combinations_of_args(combinatorial_args).map do |combined_args|
              policies_url(combined_args.merge(required_url_args))
            end
          when Announcement
            filter_option = Whitehall::AnnouncementFilterOption.find_by_search_format_types(edition.search_format_types)
            combinatorial_args << {announcement_filter_option: filter_option.slug} unless filter_option.nil?
            all_combinations_of_args(combinatorial_args).map do |combined_args|
              announcements_url(combined_args.merge(required_url_args))
            end
          when Publicationesque
            filter_option = Whitehall::PublicationFilterOption.find_by_search_format_types(edition.search_format_types)
            combinatorial_args << {publication_filter_option: filter_option.slug} unless filter_option.nil?
            all_combinations_of_args(combinatorial_args).map do |combined_args|
              publications_url(combined_args.merge(required_url_args))
            end
          end
        end

        tag_paths << atom_feed_url(format: :atom, host: Whitehall.public_host, protocol: Whitehall.public_protocol)

        tag_paths.flatten
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

      def notify!
        if (tags = govuk_delivery_tags).any?
          # Swallow all errors for the time being
          begin
            response = Whitehall.govuk_delivery_client.notify(tags, title, govuk_delivery_email_body)
          rescue GdsApi::HTTPErrorResponse => e
            Rails.logger.warn e
          rescue => e
            Rails.logger.error e
          end
        end
      end

      def url
        document_url(edition, host: Whitehall.public_host)
      end

      def public_date
        if notification_date
          notification_date.strftime('%e %B, %Y at %I:%M%P')
        end
      end

      def change_note
        if edition.document.change_history.length > 1
          edition.document.change_history.first.note
        end
      end

      def description
        [change_note, summary].compact.join('<br /><br />')
      end

      def govuk_delivery_email_body
        ERB.new(%q{
  <div class="rss_item" style="margin-bottom: 2em;">
    <div class="rss_title" style="font-size: 120%; margin: 0 0 0.3em; padding: 0;">
      <% if change_note %>Updated<% end %>
      <a href="<%= url %>" style="font-weight: bold; "><%= title %></a>
    </div>
    <% if public_date %>
      <div class="rss_pub_date" style="font-size: 90%; margin: 0 0 0.3em; padding: 0; color: #666666; font-style: italic;"><%= public_date %></div>
    <% end %>
    <br />
    <div class="rss_description" style="margin: 0 0 0.3em; padding: 0;"><%= description %></div>
  </div>
  }.encode("UTF-8")).result(binding)
      end

    end
  end
end
