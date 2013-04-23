class Whitehall::GovUkDelivery::GovUkDeliveryEndPoint < Whitehall::GovUkDelivery::NotificationEndPoint
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

  def tags
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
    Delayed::Job.enqueue GovUkDeliveryNotificationJob.new(self)
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
    [escape(change_note), escape(summary)].delete_if(&:blank?).join('<br /><br />')
  end

  def public_date_html
    if public_date
      %Q(<div class="rss_pub_date" style="font-size: 90%; margin: 0 0 0.3em; padding: 0; color: #666666; font-style: italic;">#{public_date}</div>)
    end
  end

  def email_body
    %Q( <div class="rss_item" style="margin-bottom: 2em;">
          <div class="rss_title" style="font-size: 120%; margin: 0 0 0.3em; padding: 0;">
            #{'Updated' if change_note}
            <a href="#{url}" style="font-weight: bold; ">#{escape(title)}</a>
          </div>
          #{public_date_html}
          <br />
          <div class="rss_description" style="margin: 0 0 0.3em; padding: 0;">#{description}</div>
        </div> )
  end

  private

  def escape(string)
    ERB::Util.html_escape(string)
  end
end
