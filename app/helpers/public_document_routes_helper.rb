module PublicDocumentRoutesHelper
  def public_document_path(document, options = {})
    if document.is_a?(ConsultationResponse)
      polymorphic_path(document.class.name.split("::").first.underscore, options.merge(consultation_id: document.consultation.document_identity))
    else
      polymorphic_path(document.class.name.split("::").first.underscore, options.merge(id: document.document_identity))
    end
  end
end