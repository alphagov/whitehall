require 'data_hygiene/publishing_api_republisher'

DataHygiene::PublishingApiRepublisher.new(WorldwideOrganisation.all).perform
