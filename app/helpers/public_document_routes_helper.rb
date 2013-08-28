module PublicDocumentRoutesHelper
  def public_host
    Whitehall.public_host_for(request.host) if defined?(request) && request
  end

  def document_path(edition, options = {})
    defaults = { id: edition.document }
    defaults[:locale] = edition.locale if edition.non_english_edition?
    polymorphic_path(model_name_for_route_recognition(edition), defaults.merge(options))
  end

  def public_document_path(edition, options = {})
    document_path(edition, options)
  end

  def preview_document_path(edition, options = {})
    query = {
      preview: edition.latest_edition.id,
      cachebust: Time.zone.now.getutc.to_i
    }

    document_path(edition, options.merge(query))
  end

  def preview_html_version_path(edition, html_version)
    query = {
      preview: html_version.id,
      cachebust: Time.zone.now.getutc.to_i
    }

    case edition.type
    when 'Publication'
      publication_html_version_path(edition.document, html_version, query)
    when 'Consultation'
      consultation_html_version_path(edition.document, html_version, query)
    end
  end

  def document_url(edition, options = {})
    defaults = { id: edition.document }
    defaults[:locale] = edition.locale if edition.non_english_edition?
    polymorphic_url(model_name_for_route_recognition(edition), defaults.merge(options))
  end

  def public_document_url(edition, options = {})
    document_url edition, {host: public_host}.merge(options)
  end

  def preview_document_url(edition, options = {})
    query = {
      preview: edition.latest_edition.id,
      cachebust: Time.zone.now.getutc.to_i
    }
    document_url(edition, options.merge(query))
  end

  def public_supporting_page_path(edition, supporting_page, options = {})
    policy_supporting_page_path(edition.document, supporting_page, options)
  end

  def public_supporting_page_url(edition, supporting_page, options = {})
    policy_supporting_page_url(edition.document, supporting_page, options.merge(host: public_host))
  end

  def edit_admin_supporting_page_path(supporting_page, options = {})
    edit_admin_edition_supporting_page_path(supporting_page.edition, supporting_page.id, options)
  end

  def edit_admin_supporting_page_url(supporting_page, options = {})
    edit_admin_edition_supporting_page_url(supporting_page.edition, supporting_page.id, options)
  end

  def admin_supporting_page_path(supporting_page, options = {})
    admin_edition_supporting_page_path(supporting_page.edition, supporting_page.id, options)
  end

  def admin_supporting_page_url(supporting_page, options = {})
    admin_edition_supporting_page_url(supporting_page.edition, supporting_page.id, options)
  end

  # NOTE: This method could (possibly) be dropped once Draper has been removed/replaced.
  def model_name_for_route_recognition(edition)
    klass = edition.to_model.class
    klass.name.underscore
  end
end
