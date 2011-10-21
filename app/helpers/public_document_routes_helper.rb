module PublicDocumentRoutesHelper
  def public_document_path(document, *args)
    polymorphic_path(document.class.name.underscore, id: document.document_identity.to_param)
  end
end