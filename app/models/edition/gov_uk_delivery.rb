# encoding: utf-8
require 'uri'
require 'erb'

require 'gds_api/exceptions'

module Edition::GovUkDelivery
  include Rails.application.routes.url_helpers
  extend ActiveSupport::Concern

  included do
    set_callback(:publish, :after) { notify_govuk_delivery }
  end

  def govuk_delivery_tags
    if can_be_associated_with_topics? || can_be_related_to_policies?
      topic_slugs = topics.map(&:slug)
    else
      topic_slugs = []
    end

    org_slugs = organisations.map(&:slug)

    tags = [org_slugs, topic_slugs].inject(&:product)

    required_url_args = { format: :atom, host: Whitehall.public_host, protocol: Whitehall.public_protocol }
    required_url_args[:relevant_to_local_government] = 1 if relevant_to_local_government?
    tag_paths = tags.map do |t|
      combinatorial_args = [{departments: [t[0]]}, {topics: [t[1]]}]
      case self
      when Policy
        all_combinations_of_args(combinatorial_args).map do |combined_args|
          policies_url(combined_args.merge(required_url_args))
        end
      when Announcement
        filter_option = Whitehall::AnnouncementFilterOption.find_by_search_format_types(self.search_format_types)
        combinatorial_args << {announcement_filter_option: filter_option.slug}
        all_combinations_of_args(combinatorial_args).map do |combined_args|
          announcements_url(combined_args.merge(required_url_args))
        end
      when Publicationesque
        filter_option = Whitehall::PublicationFilterOption.find_by_search_format_types(self.search_format_types)
        combinatorial_args << {publication_filter_option: filter_option.slug}
        all_combinations_of_args(combinatorial_args).map do |combined_args|
          publications_url(combined_args.merge(required_url_args))
        end
      end
    end

    tag_paths << atom_feed_url(format: :atom, host: Whitehall.public_host, protocol: Whitehall.public_protocol)

    tag_paths.flatten
  end

  def can_be_sent_as_notification?
    !minor_change? &&
      # We don't want to send anything that will appear to have been
      # published in the past.
      (Time.zone.now.to_date == notification_date.to_date)
  end

  def notification_date
    if is_a? Speech
      major_change_published_at
    else
      public_timestamp
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

  def notify_govuk_delivery
    if (tags = govuk_delivery_tags).any? && can_be_sent_as_notification?
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

  def govuk_delivery_email_body
    url = document_url(self, host: Whitehall.public_host)
    change_note = if document.change_history.length > 1
      document.change_history.first.note
    end
    if public_date = notification_date
      # Desired format is: 14 June, 2012 at 6:48pm
      public_date = public_date.strftime('%e %B, %Y at %I:%M%P')
    end
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
    <div class="rss_description" style="margin: 0 0 0.3em; padding: 0;"><%= change_note || summary %></div>
  </div>
}.encode("UTF-8")).result(binding)
  end
end
