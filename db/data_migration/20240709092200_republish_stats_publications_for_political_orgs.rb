selected_political_org_slugs = %w[
  department-for-energy-security-and-net-zero
  department-for-business-and-trade
  department-for-science-innovation-and-technology
  department-for-culture-media-and-sport
  office-for-health-improvement-and-disparities
]

selected_political_org_slugs.each do |slug|
  organisation = Organisation.where(slug:).first
  published_publications = organisation.editions.published.where(type: "publication")
  published_publications.select(&:statistics?).each do |publication|
    PublishingApiDocumentRepublishingWorker.perform_async(publication.document_id)
  end
end
