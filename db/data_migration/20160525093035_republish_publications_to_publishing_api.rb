Publication.includes(:document).order("id DESC").limit(1000).each do |pub|
  Whitehall::PublishingApi.republish_document_async(pub.document, bulk: true)
end
