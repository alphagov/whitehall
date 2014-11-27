DataHygiene::PublishingApiRepublisher.new(Organisation).perform
DataHygiene::PublishingApiRepublisher.new(WorldLocation).perform
DataHygiene::PublishingApiRepublisher.new(Edition.published).perform
