module PublicDocumentRoutesHelper
  def public_document_path(document, options = {})
    options.merge!(doc_identity_url_options(document))
    polymorphic_path(model_name(document), options)
  end

  def public_document_url(document, options={})
    options.merge!(doc_identity_url_options(document))
    if host = Whitehall.public_host_for(request.host)
      polymorphic_url(model_name(document), options.merge(host: host))
    else
      public_document_path(document, options)
    end
  end

  def public_supporting_page_path(document, supporting_page, options = {})
    policy_supporting_page_path(document.doc_identity, supporting_page, options)
  end

  def public_supporting_page_url(document, supporting_page, options={})
    if host = Whitehall.public_host_for(request.host)
      policy_supporting_page_url(document.doc_identity, supporting_page, options.merge(host: host))
    else
      public_supporting_page_path(document, supporting_page, options)
    end
  end

  def edit_admin_supporting_page_path(supporting_page, options={})
    edit_admin_document_supporting_page_path(supporting_page.document, supporting_page, options)
  end

  def edit_admin_supporting_page_url(supporting_page, options={})
    edit_admin_document_supporting_page_url(supporting_page.document, supporting_page, options)
  end

  def admin_supporting_page_path(supporting_page, options={})
    admin_document_supporting_page_path(supporting_page.document, supporting_page, options)
  end

  def admin_supporting_page_url(supporting_page, options={})
    admin_document_supporting_page_url(supporting_page.document, supporting_page, options)
  end

  private

  def doc_identity_url_options(document)
    if document.is_a?(ConsultationResponse)
      {consultation_id: document.consultation.doc_identity}
    else
      {id: document.doc_identity}
    end
  end

  def model_name(document)
    document.class.name.split("::").first.underscore
  end
end
