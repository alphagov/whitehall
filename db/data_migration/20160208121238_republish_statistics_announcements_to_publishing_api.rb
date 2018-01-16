statistics_announcements = StatisticsAnnouncement.unscoped.where.not(content_id: "")
republisher = DataHygiene::PublishingApiRepublisher.new(statistics_announcements)
republisher.perform
