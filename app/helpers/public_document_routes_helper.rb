module PublicDocumentRoutesHelper
  def public_document_path(document, options = {})
    options.merge!(document_identity_url_options(document))
    polymorphic_path(model_name(document), options)
  end

  def public_document_url(document, options={})
    options.merge!(document_identity_url_options(document))
    if host = Whitehall.public_host_for(request.host)
      polymorphic_url(model_name(document), options.merge(host: host))
    else
      public_document_path(document, options)
    end
  end

  def public_supporting_page_path(document, supporting_page, options = {})
    policy_supporting_page_path(document.document_identity, supporting_page, options)
  end

  def public_supporting_page_url(document, supporting_page, options={})
    if host = Whitehall.public_host_for(request.host)
      policy_supporting_page_url(document.document_identity, supporting_page, options.merge(host: host))
    else
      public_supporting_page_path(document, supporting_page, options)
    end
  end

  private

  def document_identity_url_options(document)
    if document.is_a?(ConsultationResponse)
      {consultation_id: document.consultation.document_identity}
    else
      {id: document.document_identity}
    end
  end

  def model_name(document)
    document.class.name.split("::").first.underscore
  end
end