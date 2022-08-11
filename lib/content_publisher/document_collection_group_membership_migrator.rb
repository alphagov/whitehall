module ContentPublisher
  class DocumentCollectionGroupMembershipMigrator
    attr_reader :document

    def initialize(document)
      @document = document
    end

    def call
      edition = document.live_edition || document.latest_edition

      return unless DocumentCollectionGroupMembership.exists?(document_id: document.id)

      non_whitehall_link = DocumentCollectionNonWhitehallLink.create!(
        content_id: document.content_id,
        title: edition.title,
        base_path: Whitehall.url_maker.public_document_path(edition),
        publishing_app: "content-publisher",
      )

      DocumentCollectionGroupMembership
        .where(document_id: document.id)
        .update_all(
          document_id: nil,
          non_whitehall_link_id: non_whitehall_link.id,
        )
    end
  end
end
