module Import
  class HmctsDraftCreator
    def create_drafts(csv_path, pause_seconds)
      CSV.read(csv_path, headers: true).each do |row|
        publication_id = row["publication whitehall ID"]
        publication = Publication.find_by(id: publication_id)

        puts "Creating draft preview of #{publication_id}: '#{publication.slug}'"

        Whitehall.edition_services.draft_updater(publication).perform!

        # Prevent the HMCTS import from overloading whitehall's publishing
        # queue, blocking other documents from being published.
        sleep(pause_seconds)
      end
    end
  end
end
