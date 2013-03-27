require 'uri'
module Edition::GovUkDelivery
  include Rails.application.routes.url_helpers
  extend ActiveSupport::Concern

  included do
    set_callback(:publish, :after) { notify_govuk_delivery }
  end

  def notify_govuk_delivery
    if can_be_associated_with_topics? || can_be_related_to_policies?
      topic_slugs = topics.map(&:slug)
    else
      topic_slugs = []
    end

    org_slugs = organisations.map(&:slug)

    tags = [org_slugs, topic_slugs].inject(&:product).map(&:flatten)
    puts tags.inspect
    tag_paths = tags.map do |t|
      case
      when self.search_format_types.include?(Policy.search_format_type)
        if relevant_to_local_government?
          policies_path(departments: [t[0]], topics: [t[1]], relevant_to_local_government: true)
        else
          policies_path(departments: [t[0]], topics: [t[1]])
        end
      when self.search_format_types.include?(Announcement.search_format_type)
        filter_option = Whitehall::AnnouncementFilterOption.find_by_search_format_types(self.search_format_types)
        if relevant_to_local_government?
          announcements_path(announcement_type_option: filter_option.slug, departments: [t[0]], topics: [t[1]], relevant_to_local_government: true)
        else
          announcements_path(announcement_type_option: filter_option.slug, departments: [t[0]], topics: [t[1]])
        end
      end
    end
    puts tag_paths.inspect

    payload = {title: title, summary: summary, link: public_document_path(self), tags: tag_paths}

    if %w{test development}.include?(Whitehall.platform)
      puts "*" * 80
      puts "payload: #{payload.inspect}"
    else
      conn = Faraday.new url: Whitehall.govuk_delivery_url do |faraday|
        faraday.response :logger                  # log requests to STDOUT
        faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
      end

      conn.post do |req|
        req.url "/send-email"
        req.body = payload.to_json
      end
    end
  end
end
