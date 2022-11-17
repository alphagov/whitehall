module PublicDocumentRoutesHelper
  include ActionDispatch::Routing::PolymorphicRoutes

  def document_path(edition, query_parameters: {})
    locale = if edition.non_english_edition?
               edition.primary_locale
             elsif edition.translatable? && edition.available_in_locale?(I18n.locale)
               I18n.locale
             else
               I18n.default_locale
             end

    locale_suffix = locale == I18n.default_locale ? "" : ".#{locale}"
    query_suffix = query_parameters.any? ? "?#{query_parameters.to_query}" : ""

    # could be better just asking an edition for this?
    case edition
    when DocumentCollection
      "/collections/#{edition.slug}#{locale_suffix}#{query_suffix}"
    # and the other edition types...
    else
      raise "Unexpected edition type #{e.class}"
    end
  end

  def public_document_url(edition)
    Plek.new.website_root + document_path(edition)
  end

  def preview_document_url(edition, query_parameters: {})
    if edition.rendering_app == Whitehall::RenderingApp::WHITEHALL_FRONTEND
      # not sure what to do for Whitehall hosted ones still? is perhaps
      # that we still have them for worldwide organisation corporate information
      # pages and these seem broken?
      # options[:preview] = edition.document.latest_edition_id
      # options[:cachebust] = Time.zone.now.getutc.to_i
    else
      Plek.new.external_url_for("draft-origin") + document_path(edition, query_parameters:)
    end
  end

  def preview_document_url_with_auth_bypass_token(edition)
    preview_document_url(edition, query_parameters: {
      token: edition.auth_bypass_token,
      utm_source: :share,
      utm_medium: :preview,
      utm_campaign: :govuk_publishing,
    })
  end

  def organisation_url(slug_or_organisation, options = {})
    organisation_or_court = case slug_or_organisation
                            when String
                              Organisation.find_by(slug: slug_or_organisation)
                            when Organisation
                              slug_or_organisation
                            else
                              raise ArgumentError, "Must provide a slug or Organisation"
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

  def get_involved_path(options = {})
    append_url_options("/government/get-involved", options)
  end

  def get_involved_url(options = {})
    Plek.new.website_root + get_involved_path(options)
  end

  def take_part_page_path(object, options = {})
    slug = case object
           when String
             object
           when TakePartPage
             object.slug
           else
             raise ArgumentError, "Must provide a slug or TakePartPage"
           end

    append_url_options("/government/get-involved/take-part/#{slug}", options)
  end

  def take_part_page_url(object, options = {})
    Plek.new.website_root + take_part_page_path(object, options)
  end

  def topical_event_path(object, options = {})
    slug = case object
           when String
             object
           when TopicalEvent
             object.slug
           else
             raise ArgumentError, "Must provide a slug or TopicalEvent"
           end

    append_url_options("/government/topical-events/#{slug}", options)
  end

  def topical_event_url(object, options = {})
    Plek.new.website_root + topical_event_path(object, options)
  end

  def topical_event_about_pages_path(object, options = {})
    slug = case object
           when String
             object
           when TopicalEvent
             object.slug
           when TopicalEventAboutPage
             object.topical_event.slug
           else
             raise ArgumentError, "Must provide a slug, TopicalEvent or TopicalEventAboutPage"
           end

    append_url_options("/government/topical-events/#{slug}/about", options)
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

  def append_url_options(path, options = {})
    if options[:format] && options[:locale]
      path = "#{path}.#{options[:locale]}.#{options[:format]}"
    elsif options[:locale]
      path = "#{path}.#{options[:locale]}"
    elsif options[:format]
      path = "#{path}.#{options[:format]}"
    end

    if options[:cachebust]
      query_params = {
        cachebust: options[:cachebust],
      }
      path = "#{path}?#{query_params.to_query}"
    end

    path
  end
end
