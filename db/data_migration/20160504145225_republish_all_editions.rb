Document
  .includes(:live_edition, :pre_publication_edition)
  .find_each { |d| Whitehall::PublishingApi.republish_document_async(d, bulk: true) }
