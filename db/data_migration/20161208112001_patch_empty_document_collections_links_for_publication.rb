pub = Publication.find(124751)

links = PublishingApiPresenters.presenter_for(pub).links

if links
  # Explicitly set the document_collections links to an empty set
  # these links are resolved by the Publishing API
  links[:document_collections] = []
  Whitehall.publishing_api_v2_client.patch_links(
    pub.document.content_id,
    links: links,
    bulk_publishing: true
  )
end
