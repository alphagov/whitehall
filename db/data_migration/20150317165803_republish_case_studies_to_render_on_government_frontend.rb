# Unpublished case studies
DataHygiene::PublishingApiRepublisher.new(CaseStudy.archived).perform
DataHygiene::PublishingApiRepublisher.new(CaseStudy.publicly_visible).perform

case_study_unpublishings = Unpublishing.joins(:edition).where(editions: { type: CaseStudy })
DataHygiene::PublishingApiRepublisher.new(case_study_unpublishings).perform
