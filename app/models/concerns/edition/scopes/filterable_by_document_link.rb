module Edition::Scopes::FilterableByDocumentLink
  extend ActiveSupport::Concern

  included do
    scope :linked_to_document, lambda { |linked_document|
      joins("INNER JOIN edition_links ON edition_links.edition_id = editions.id")
        .where(edition_links: { document_id: linked_document.id })
    }
  end
end
