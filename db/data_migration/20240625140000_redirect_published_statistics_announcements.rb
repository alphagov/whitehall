StatisticsAnnouncement.published.find_each do |statistics_announcement|
  Whitehall::PublishingApi.publish_redirect_async(statistics_announcement.content_id, statistics_announcement.publication.base_path) if statistics_announcement.publication.present? && statistics_announcement.publication.published?
end
