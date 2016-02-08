StatisticsAnnouncement.where.not(content_id: "").find_each(batch_size: 100) do |statistics_announcement|
  statistics_announcement.publish_to_publishing_api
end

