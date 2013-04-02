require 'uri'
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
          policies_url(departments: [t[0]], topics: [t[1]], relevant_to_local_government: true, format: :atom, host: Whitehall.public_host, protocol: Whitehall.public_protocol)
        else
          policies_url(departments: [t[0]], topics: [t[1]], format: :atom, host: Whitehall.public_host, protocol: Whitehall.public_protocol)
        end
      when Announcement
        filter_option = Whitehall::AnnouncementFilterOption.find_by_search_format_types(self.search_format_types)
        if relevant_to_local_government?
          announcements_url(announcement_type_option: filter_option.slug, departments: [t[0]], topics: [t[1]], relevant_to_local_government: true, format: :atom, host: Whitehall.public_host, protocol: Whitehall.public_protocol)
        else
          announcements_url(announcement_type_option: filter_option.slug, departments: [t[0]], topics: [t[1]], format: :atom, host: Whitehall.public_host, protocol: Whitehall.public_protocol)
        end
      when Publicationesque
        filter_option = Whitehall::PublicationFilterOption.find_by_search_format_types(self.search_format_types)
        if relevant_to_local_government?
          publications_url(publication_filter_option: filter_option.slug, departments: [t[0]], topics: [t[1]], relevant_to_local_government: true, format: :atom, host: Whitehall.public_host, protocol: Whitehall.public_protocol)
        else
          publications_url(publication_filter_option: filter_option.slug, departments: [t[0]], topics: [t[1]], format: :atom, host: Whitehall.public_host, protocol: Whitehall.public_protocol)
        end
      end
    end

    tag_paths
  end

  def notify_govuk_delivery
    if (tags = govuk_delivery_tags).any?
      #payload = {title: title, summary: summary, link: public_document_path(self), tags: tags}
      # Swallow all errors for the time being
      begin
        response = Whitehall.govuk_delivery_client.notify(tags, title, '')
      rescue GdsApi::HTTPErrorResponse
        nil
      end
    end
  end

end
