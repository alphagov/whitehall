module PublicDocumentRoutesHelper
  include ActionDispatch::Routing::PolymorphicRoutes

  def document_path(edition, options = {})
    document_url(edition, options.merge(only_path: true))
  end

  def public_document_path(edition, options = {})
    document_path(edition, options)
  end

  def preview_document_path(edition, options = {})
    query = { preview: edition.latest_edition.id, cachebust: Time.zone.now.getutc.to_i }
    document_path(edition, options.merge(query))
  end

  def document_url(edition, options = {}, _builder_options = {})
    return edition.link if edition.is_a? RummagerDocumentPresenter

    if edition.non_english_edition?
      options[:locale] = edition.primary_locale
    elsif edition.translatable?
      options[:locale] ||= best_locale_for_edition(edition)
    else
      options.delete(:locale)
    end

    case edition
    when CorporateInformationPage
      build_url_for_corporate_information_page(edition, options)
    else
      path_name = if edition.statistics?
                    "statistic"
                  else
                    edition.to_model.class.name.underscore
                  end
      polymorphic_url(path_name, options.reverse_merge(id: edition.document))
    end
  end

  def public_document_url(edition, options = {}, builder_options = {})
    document_url(
      edition,
      { host: Whitehall.public_host, protocol: Whitehall.public_protocol }.merge(options),
      builder_options,
    )
  end

  def preview_document_url(edition, options = {})
    if edition.rendering_app == Whitehall::RenderingApp::GOVERNMENT_FRONTEND
      options[:host] = URI(Plek.new.external_url_for("draft-origin")).host
    else
      options[:preview] = edition.latest_edition.id
      options[:cachebust] = Time.zone.now.getutc.to_i
    end

    document_url(edition, options)
  end

  def organisation_url(slug_or_organisation, options = {})
    organisation_or_court = case slug_or_organisation
                            when String
                              Organisation.find_by(slug: slug_or_organisation)
                            when Organisation
                              slug_or_organisation
                            else
                              raise ArgumentError.new("Must provide a slug or Organisation")
                            end

    if organisation_or_court.nil?
      logger.warn "Generating a URL for a missing organisation: #{slug_or_organisation}"
      return super(slug_or_organisation, options)
    end

    if organisation_or_court.court_or_hmcts_tribunal?
      court_url(organisation_or_court, options)
    else
      super(organisation_or_court, options)
    end
  end

  def organisation_path(organisation_or_court_or_slug, options = {})
    organisation_url(organisation_or_court_or_slug, options.merge(only_path: true))
  end

  def organisation_preview_url(organisation, options = {})
    polymorphic_url(organisation, options.merge(host: URI(Plek.new.external_url_for("draft-origin")).host))
  end

private

  def build_url_for_corporate_information_page(edition, options)
    org = edition.owning_organisation

    decorator = CorporateInfoPageDecorator.new(edition)
    url = polymorphic_url([org, decorator], options)

    # About pages are actually shown on the CIP index for an Organisation.
    # We generate a unique path for them anyway, but this is always redirected.
    case org
    when Organisation
      url.gsub("/about/about", "/about")
    when WorldwideOrganisation
      url.gsub("/about/about", "")
    end
  end

  def best_locale_for_edition(edition)
    if I18n.locale != I18n.default_locale && edition.available_in_locale?(I18n.locale)
      I18n.locale
    else
      I18n.default_locale
    end
  end

  # Override #to_s on corporate information pages to return a slug.
  # We could set the FriendlyId in the model, but this would affect admin.
  CorporateInfoPageDecorator = Struct.new(:edition) do
    delegate :slug, :persisted?, :model_name, to: :edition

    def to_s
      slug
    end

    def to_model
      self
    end
  end
end
