module PublicDocumentRoutesHelper
  def public_document_path(edition, options = {})
    if edition.is_a?(ConsultationResponse)
      consultation_path(edition.consultation.document)
    else
      polymorphic_path(model_name(edition), options.merge(id: edition.document))
    end
  end

  def public_document_url(edition, options={})
    if host = Whitehall.public_host_for(request.host)
      options.merge!(host: host)
    end

    if edition.is_a?(ConsultationResponse)
      consultation_url(edition.consultation.document, options)
    else
      polymorphic_url(model_name(edition), options.merge(id: edition.document))
    end
  end

  def public_supporting_page_path(edition, supporting_page, options = {})
    policy_supporting_page_path(edition.document, supporting_page, options)
  end

  def public_supporting_page_url(edition, supporting_page, options={})
    if host = Whitehall.public_host_for(request.host)
      policy_supporting_page_url(edition.document, supporting_page, options.merge(host: host))
    else
      public_supporting_page_path(edition, supporting_page, options)
    end
  end

  def edit_admin_supporting_page_path(supporting_page, options={})
    edit_admin_edition_supporting_page_path(supporting_page.edition, supporting_page, options)
  end

  def edit_admin_supporting_page_url(supporting_page, options={})
    edit_admin_edition_supporting_page_url(supporting_page.edition, supporting_page, options)
  end

  def admin_supporting_page_path(supporting_page, options={})
    admin_edition_supporting_page_path(supporting_page.edition, supporting_page, options)
  end

  def admin_supporting_page_url(supporting_page, options={})
    admin_edition_supporting_page_url(supporting_page.edition, supporting_page, options)
  end

  private

  def model_name(edition)
    edition.class.name.split("::").first.underscore
  end
end
