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
      @new_slug = new_slug.strip
    end

    def run!
      add_errors_if_invalid
      return false if document.errors.present?

      save_document
      republish_document
      create_editorial_remark
      true
    end

  private

    def add_errors_if_invalid
      document.errors.add(:slug, "is blank") and return if new_slug.blank?

      document.errors.add(:slug, "must be unique") and return if new_slug_is_a_duplicate

      document.errors.add(:slug, "should not start with a slash") if new_slug.starts_with?("/")
    end

    def new_slug_is_a_duplicate
      documents = Document.where(document_type: document.document_type, slug: new_slug)
      documents.present? && documents != [document]
    end

    def save_document
      document.update!(slug: new_slug)
    end

    def republish_document
      PublishingApiDocumentRepublishingWorker.new.perform(document.id)
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
