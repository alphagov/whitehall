stuck_draft_editions = [
  #/government/statistics/statistical-release-provisional-uk-official-development-assistance-oda-as-a-proportion-of-gross-national-income-2012
  167273,
  #/government/statistics/statistical-release-provisional-uk-official-development-assistance-oda-tables-2012
  167561
]

stuck_draft_editions.each do |edition_id|
  stuck_draft = Edition.find(edition_id)
  stuck_draft.state = "superseded"
  stuck_draft.save(validate: false) #this is what the EditionPublisher service does, sorry.

  PublishingApiDocumentRepublishingWorker.perform_async(stuck_draft.document_id)
end

