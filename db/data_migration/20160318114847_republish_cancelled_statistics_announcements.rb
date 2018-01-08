DataHygiene::PublishingApiRepublisher
  .new(StatisticsAnnouncement.unscoped.where("cancelled_at is not null"))
  .perform
