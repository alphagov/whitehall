module DataHygiene
  # Reslugs a document to new_slug.
  #
  # When run, the following happens:
  #
  #  - changes the documents slug
  #  - reindexes the document with it's new slug
  #  - republishes the document to Publishing API (automatically handles the redirect)
  #
  class DocumentReslugger
    attr_reader :document, :published_edition, :current_user, :new_slug

    def initialize(document, published_edition, current_user, new_slug)
      @document = document
      @published_edition = published_edition
      @current_user = current_user
      @new_slug = new_slug
    end

    def run!
      add_errors_if_invalid
      return false if document.errors.present?

      remove_from_search_index
      save_document
      republish_document
      add_to_search_index
      create_editorial_remark
      true
    end

  private

    def add_errors_if_invalid
      document.errors.add(:slug, "is blank") and return if new_slug.blank?

      document.errors.add(:slug, "must be unique") and return if new_slug_is_a_duplicate

      document.errors.add(:slug, "is invalid") unless new_slug.starts_with?("/") && new_slug !~ %r{//} && new_slug !~ %r{./\z}
    end

    def new_slug_is_a_duplicate
      documents = Document.where(slug: new_slug)
      documents.present? && documents != [document]
    end

    def remove_from_search_index
      Whitehall::SearchIndex.delete(published_edition)
    end

    def save_document
      document.update!(slug: new_slug)
    end

    def republish_document
      PublishingApiDocumentRepublishingWorker.new.perform(document.id)
    end

    def add_to_search_index
      Whitehall::SearchIndex.add(published_edition)
    end

    def create_editorial_remark
      published_edition.editorial_remarks.create!(
        body: "Updated document slug to #{document.slug}",
        author: current_user,
        created_at: Time.zone.now,
        updated_at: Time.zone.now,
      )
    end
  end
end
