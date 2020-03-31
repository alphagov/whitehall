document = Document.find(305774)
editions = document.editions.order(:created_at)
correct_first_published_at = editions.first.first_published_at

editions.each do |edition|
  if edition.first_published_at != correct_first_published_at
    edition.first_published_at = correct_first_published_at
    edition.save(validate: false)
  end
end

PublishingApiDocumentRepublishingWorker.new.perform(document.id)
