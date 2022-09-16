pub = Publication.find(124_751)

links = PublishingApiPresenters.presenter_for(pub).links

if links
  # Explicitly set the document_collections links to an empty set
  # these links are resolved by the Publishing API
  links[:document_collections] = []
  Services.publishing_api.patch_links(
    pub.document.content_id,
    links:,
    bulk_publishing: true,
  )
end
