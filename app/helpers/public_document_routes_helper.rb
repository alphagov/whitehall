module PublicDocumentRoutesHelper
  def public_document_path(document, options = {})
    polymorphic_path(document.class.name.split("::").first.underscore, options.merge(id: document.document_identity))
  end
end