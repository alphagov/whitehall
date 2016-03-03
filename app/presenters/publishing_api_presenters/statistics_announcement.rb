require_relative "../publishing_api_presenters"

class PublishingApiPresenters::StatisticsAnnouncement < PublishingApiPresenters::Item
private

  def filter_links
    [
      :organisations,
      :policy_areas,
      :topics,
    ]
  end

  def details
    {
      display_date: item.current_release_date.display_date,
      state: item.state,
      format_sub_type: item.national_statistic? ? "national" : "official"
    }
  end

  def document_format
    "statistics_announcement"
  end

  def description
    item.summary
  end

  def public_updated_at
    item.updated_at
  end
end
