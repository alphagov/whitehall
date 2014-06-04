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
    if edition.non_english_edition?
      options[:locale] = edition.locale
    elsif edition.translatable?
      options[:locale] ||= best_locale_for_edition(edition)
    else
      options.delete(:locale)
    end

    case edition
    when CorporateInformationPage
      build_url_for_corporate_information_page(edition, options)
    when SupportingPage
      build_url_for_supporting_page(edition, options)
    else
      polymorphic_url(edition.to_model.class.name.underscore,
                      options.reverse_merge(id: edition.document))
    end
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

private

  def build_url_for_corporate_information_page(edition, options)
    org = edition.owning_organisation
    # About pages are actually shown on the CIP index for an Organisation.
    # But sub-orgs and worldwide orgs show the about text on the org page itself.
    if edition.about_page?
      if org.is_a?(WorldwideOrganisation) || org.organisation_type.sub_organisation?
        polymorphic_url([org], options)
      else
        polymorphic_url([org, CorporateInformationPage], options)
      end
    else
      polymorphic_url([org, 'corporate_information_page'], options.merge(id: edition.slug))
    end
  end

  def build_url_for_supporting_page(edition, options)
    options.merge!(policy_id: edition.related_policies.first.document, id: edition.document)
    polymorphic_url('policy_supporting_page', options)
  end

  def best_locale_for_edition(edition)
    if edition.non_english_edition?
      edition.locale
    elsif I18n.locale != I18n.default_locale && edition.available_in_locale?(I18n.locale)
      I18n.locale
    else
      I18n.default_locale
    end
  end
end
