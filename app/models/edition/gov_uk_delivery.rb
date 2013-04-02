require 'uri'
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
          policies_path(departments: [t[0]], topics: [t[1]], relevant_to_local_government: true)
        else
          policies_path(departments: [t[0]], topics: [t[1]])
        end
      when Announcement
        filter_option = Whitehall::AnnouncementFilterOption.find_by_search_format_types(self.search_format_types)
        if relevant_to_local_government?
          announcements_path(announcement_type_option: filter_option.slug, departments: [t[0]], topics: [t[1]], relevant_to_local_government: true)
        else
          announcements_path(announcement_type_option: filter_option.slug, departments: [t[0]], topics: [t[1]])
        end
      when Publicationesque
        filter_option = Whitehall::PublicationFilterOption.find_by_search_format_types(self.search_format_types)
        if relevant_to_local_government?
          publications_path(publication_filter_option: filter_option.slug, departments: [t[0]], topics: [t[1]], relevant_to_local_government: true)
        else
          publications_path(publication_filter_option: filter_option.slug, departments: [t[0]], topics: [t[1]])
        end
      end
    end

    tag_paths
  end

  def notify_govuk_delivery
    payload = {title: title, summary: summary, link: public_document_path(self), tags: govuk_delivery_tags}
    #TODO GDS API adapter call
    puts payload.inspect
  end

end
