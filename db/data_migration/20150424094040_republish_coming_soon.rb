Edition.scheduled.each do |edition|
  unless edition.document.published?
    edition.translated_locales.each do |locale|
      PublishingApiComingSoonWorker.perform_async(edition.id, locale)
    end
  end
end
