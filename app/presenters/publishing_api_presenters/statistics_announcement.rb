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
      format_sub_type: item.national_statistic? ? "national" : "official"
    }.tap do |d|
      d.merge!(
        cancellation_reason: item.cancellation_reason,
        cancelled_at: cancelled_at
      ) if item.cancelled?
    end
  end

  def document_format
    "statistics_announcement"
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
