module LockedDocumentConcern
  extend ActiveSupport::Concern

  class LockedDocumentError < RuntimeError; end

  def check_if_locked_document(content_id: nil, document: nil, edition: nil)
    content_id_locked = content_id && Document.exists?(locked: true, content_id:)
    document_locked = document && document.locked?
    edition_locked = edition && edition.locked?

    if content_id_locked || document_locked || edition_locked
      raise LockedDocumentError, "Cannot perform this operation on a locked document"
    end
  end
end
