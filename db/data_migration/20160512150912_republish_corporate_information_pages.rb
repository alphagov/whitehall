CorporateInformationPage
  .published
  .includes(:document)
  .joins(:document, :translations)
  .where("locale != 'en'").each do |cip|
  Whitehall::PublishingApi.republish_document_async(cip.document)
end
