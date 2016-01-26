module PublishingApiPresenters
  class StatisticsAnnouncement < Item
    def links
      {
        organisations: item.organisations.map(&:content_id),
        policy_areas: item.topics.map(&:content_id)
      }
    end

  private

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
end
