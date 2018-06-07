module DataHygiene
  class DocumentReslugger
    def self.call(from:, to:)
      old_slug = from
      new_slug = to

      document = Document.find_by(slug: old_slug)
      return unless document

      puts "Reslugging #{old_slug} document to #{new_slug}"

      edition = document.editions.published.last
      Whitehall::SearchIndex.delete(edition)

      document.update_attributes!(slug: new_slug)
      PublishingApiDocumentRepublishingWorker.new.perform(document.id)
    end
  end
end
