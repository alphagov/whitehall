require "data_hygiene/publishing_api_republisher"

DataHygiene::PublishingApiRepublisher.new(Organisation.all).perform
DataHygiene::PublishingApiRepublisher.new(WorldwideOrganisation.all).perform
DataHygiene::PublishingApiRepublisher.new(WorldLocation.all).perform
