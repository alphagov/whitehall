module LockedDocumentConcern
  extend ActiveSupport::Concern

  class LockedDocumentError < RuntimeError; end

  def check_if_locked_document(content_id: nil)
    content_id_locked = content_id && Document.exists?(locked: true, content_id: content_id)

    if content_id_locked
      raise LockedDocumentError, "Cannot perform this operation on a locked document"
    end
  end
end
