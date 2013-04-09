module Edition::GovUkDelivery
  include Rails.application.routes.url_helpers
  extend ActiveSupport::Concern

  included do
    set_callback :publish, :after, :notify_govuk_delivery, unless: :minor_change?
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

  def notify_govuk_delivery
    if can_be_sent_as_notification?
      Delayed::Job.enqueue GovUkDeliveryNotificationJob.new(id)
    end
  end
end
