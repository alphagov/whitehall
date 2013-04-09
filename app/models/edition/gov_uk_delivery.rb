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

    tag_paths = tags.map do |t|
      case self
      when Policy
        if relevant_to_local_government?
          [
            policies_url(departments: [t[0]], topics: [t[1]], relevant_to_local_government: 1, format: :atom, host: Whitehall.public_host, protocol: Whitehall.public_protocol),
            policies_url(topics: [t[1]], relevant_to_local_government: 1, format: :atom, host: Whitehall.public_host, protocol: Whitehall.public_protocol),
            policies_url(relevant_to_local_government: 1, format: :atom, host: Whitehall.public_host, protocol: Whitehall.public_protocol),
          ]
        else
          [
            policies_url(departments: [t[0]], topics: [t[1]], format: :atom, host: Whitehall.public_host, protocol: Whitehall.public_protocol),
            policies_url(topics: [t[1]], format: :atom, host: Whitehall.public_host, protocol: Whitehall.public_protocol),
            policies_url(format: :atom, host: Whitehall.public_host, protocol: Whitehall.public_protocol)
          ]
        end
      when Announcement
        filter_option = Whitehall::AnnouncementFilterOption.find_by_search_format_types(self.search_format_types)
        if relevant_to_local_government?
          [
            announcements_url(departments: [t[0]], topics: [t[1]], relevant_to_local_government: 1, format: :atom, host: Whitehall.public_host, protocol: Whitehall.public_protocol),
            announcements_url(topics: [t[1]], relevant_to_local_government: 1, format: :atom, host: Whitehall.public_host, protocol: Whitehall.public_protocol),
            announcements_url(relevant_to_local_government: 1, format: :atom, host: Whitehall.public_host, protocol: Whitehall.public_protocol)
          ]
        else
          [
            announcements_url(departments: [t[0]], topics: [t[1]], format: :atom, host: Whitehall.public_host, protocol: Whitehall.public_protocol),
            announcements_url(topics: [t[1]], format: :atom, host: Whitehall.public_host, protocol: Whitehall.public_protocol),
            announcements_url(format: :atom, host: Whitehall.public_host, protocol: Whitehall.public_protocol)
          ]
        end
      when Publicationesque
        filter_option = Whitehall::PublicationFilterOption.find_by_search_format_types(self.search_format_types)
        if relevant_to_local_government?
          [
            publications_url(departments: [t[0]], topics: [t[1]], relevant_to_local_government: 1, format: :atom, host: Whitehall.public_host, protocol: Whitehall.public_protocol),
            publications_url(topics: [t[1]], relevant_to_local_government: 1, format: :atom, host: Whitehall.public_host, protocol: Whitehall.public_protocol),
            publications_url(relevant_to_local_government: 1, format: :atom, host: Whitehall.public_host, protocol: Whitehall.public_protocol)
          ]
        else
          [
            publications_url(departments: [t[0]], topics: [t[1]], format: :atom, host: Whitehall.public_host, protocol: Whitehall.public_protocol),
            publications_url(topics: [t[1]], format: :atom, host: Whitehall.public_host, protocol: Whitehall.public_protocol),
            publications_url(format: :atom, host: Whitehall.public_host, protocol: Whitehall.public_protocol)
          ]
        end
      end
    end

    tag_paths << atom_feed_url(format: :atom, host: Whitehall.public_host, protocol: Whitehall.public_protocol)

    tag_paths.flatten
  end

  def notify_govuk_delivery
    if (tags = govuk_delivery_tags).any? && !minor_change?
      # Swallow all errors for the time being
      begin
        response = Whitehall.govuk_delivery_client.notify(tags, title, govuk_delivery_email_body)
      rescue GdsApi::HTTPErrorResponse
        nil
      end
    end
  end

def govuk_delivery_email_body
  url = document_url(self, host: Whitehall.public_host)
  ERB.new(%q{
<div class="rss_item" style="margin-bottom: 2em;">
  <div class="rss_title" style="font-weight: bold; font-size: 120%; margin: 0 0 0.3em; padding: 0;">
    <a href="<%= url %>"><%= title %></a>
  </div>
  <div class="rss_pub_date" style="font-size: 90%; margin: 0 0 0.3em; padding: 0; color: #666666; font-style: italic;"><%= public_timestamp %></div>
  <br />
  <div class="rss_description" style="margin: 0 0 0.3em; padding: 0;"><%= summary %></div>
</div>
}.encode("UTF-8")).result(binding)
  end
end
