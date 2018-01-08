publication_ids_published_since_april = Publication.where("first_published_at > ?", Time.new(2016, 4, 1)).pluck(:id)
statistics_announcements_to_republish = StatisticsAnnouncement
  .unscoped
  .where(publication_id: publication_ids_published_since_april)

republisher = DataHygiene::PublishingApiRepublisher.new(
  statistics_announcements_to_republish
  )

republisher.perform

