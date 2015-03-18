# Unpublished case studies
DataHygiene::PublishingApiRepublisher.new(CaseStudy.archived).perform
DataHygiene::PublishingApiRepublisher.new(CaseStudy.publicly_visible).perform
