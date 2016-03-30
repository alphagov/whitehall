republisher = DataHygiene::PublishingApiRepublisher.new(Organisation.all)
republisher.perform
