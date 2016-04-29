require_relative "../publishing_api_presenters"

class PublishingApiPresenters::StatisticsAnnouncement < PublishingApiPresenters::Item
  def links
    extract_links([
      :organisations,
      :policy_areas,
      :topics,
    ])
  end

private

  def details
    {
      display_date: item.current_release_date.display_date,
      state: item.state,
      format_sub_type: document_type # deprecated
    }.tap do |d|
      d.merge!(
        cancellation_reason: item.cancellation_reason,
        cancelled_at: cancelled_at
      ) if item.cancelled?
      d.merge!(
        previous_display_date: item.previous_display_date,
        latest_change_note: item.last_change_note
      ) if item.previous_display_date
    end
  end

  def schema_name
    "statistics_announcement"
  end

  def document_type
    item.national_statistic? ? "national" : "official"
  end

  def rendering_app
    Whitehall::RenderingApp::GOVERNMENT_FRONTEND
  end

  def description
    item.summary
  end

  def public_updated_at
    item.updated_at
  end

  def cancelled_at
    return nil unless item.cancelled_at
    item.cancelled_at.to_datetime
  end
end
