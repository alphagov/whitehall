module PublicDocumentRoutesHelper
  include ActionDispatch::Routing::UrlFor

  def public_host
    if defined?(request) && request
      Whitehall.public_host_for(request.host)
    else
      Whitehall.public_host
    end
  end

  def document_path(edition, options = {})
    document_url(edition, options.merge(routing_type: :path))
  end

  def public_document_path(edition, options = {})
    document_path(edition, options)
  end

  def preview_document_path(edition, options = {})
    query = { preview: edition.latest_edition.id, cachebust: Time.zone.now.getutc.to_i }
    document_path(edition, options.merge(query))
  end

  def document_url(edition, options = {})
    if edition.is_a?(CorporateInformationPage)
      defaults = { id: edition.slug }
      if edition.owning_organisation.is_a?(Organisation)
        route_name = 'organisation_corporate_information_page'
        defaults[:organisation_id] = edition.owning_organisation
      else
        route_name = 'worldwide_organisation_corporate_information_page'
        defaults[:worldwide_organisation_id] = edition.owning_organisation
      end
    else
      defaults = { id: edition.document }
      defaults[:policy_id] = edition.related_policies.first.document if edition.is_a?(SupportingPage)
      route_name = model_name_for_route_recognition(edition)
    end
    defaults[:locale] = edition.locale if edition.non_english_edition?
    polymorphic_url(route_name, defaults.merge(options))
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

  # NOTE: This method could (possibly) be dropped once Draper has been removed/replaced.
  def model_name_for_route_recognition(edition)
    klass = edition.to_model.class
    klass == SupportingPage ? 'policy_supporting_page' : klass.name.underscore
  end
end
