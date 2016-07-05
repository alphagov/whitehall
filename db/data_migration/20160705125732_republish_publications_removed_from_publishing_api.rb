documents = Document.where(id: [313584, 321220])
documents.each do |document|
  Whitehall::PublishingApi.republish_document_async(document, bulk: true)
end

