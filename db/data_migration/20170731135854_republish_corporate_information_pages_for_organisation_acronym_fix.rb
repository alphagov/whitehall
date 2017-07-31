CorporateInformationPage
  .published
  .includes(:document).each do |cip|
  Whitehall::PublishingApi.republish_document_async(cip.document)
end
