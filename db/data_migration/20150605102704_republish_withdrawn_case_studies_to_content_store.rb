require "data_hygiene/publishing_api_republisher"

DataHygiene::PublishingApiRepublisher.new(CaseStudy.withdrawn_or_archived).perform
