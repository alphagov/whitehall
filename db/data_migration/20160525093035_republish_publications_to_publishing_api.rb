Publication.includes(:document).find_each do |pub|
  Whitehall::PublishingApi.republish_document_async(pub.document, bulk: true)
end
