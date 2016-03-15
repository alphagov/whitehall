republisher = DataHygiene::PublishingApiRepublisher.new(StatisticsAnnouncement.unscoped)
republisher.perform
