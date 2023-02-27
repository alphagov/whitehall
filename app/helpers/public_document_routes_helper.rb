module PublicDocumentRoutesHelper
  include ActionDispatch::Routing::PolymorphicRoutes

  def document_path(edition, options = {}, locale: nil)
    if options[:locale]
      throw new RuntimeError("passed through locale in #{options}")
    end

    edition.public_path(options, locale: locale(edition, locale:))
  end

  def public_document_path(edition, options = {}, locale: nil)
    document_path(edition, options, locale:)
  end

  def document_url(edition, options = {}, _builder_options = {}, locale: nil)
    return edition.url if edition.is_a?(RummagerDocumentPresenter)

    edition.public_url(options, locale: locale(edition, locale:))
  end

  def public_document_url(edition, options = {}, locale: nil)
    edition.public_url(options, locale: locale(edition, locale:))
  end

  def preview_document_url(edition, options = {}, locale:)
    if edition.rendering_app == Whitehall::RenderingApp::GOVERNMENT_FRONTEND
      options[:draft] = true
    else
      options[:preview] = edition.document.latest_edition_id
      options[:cachebust] = Time.zone.now.getutc.to_i
    end

    document_url(edition, options, locale:)
  end

  def preview_document_url_with_auth_bypass_token(edition)
    params = {
      token: edition.auth_bypass_token,
      utm_source: :share,
      utm_medium: :preview,
      utm_campaign: :govuk_publishing,
    }.to_query
    "#{preview_document_url(edition, locale: I18n.default_locale)}?#{params}"
  end

private

  def locale(edition, locale:)
    if edition.non_english_edition?
      edition.primary_locale
    elsif edition.translatable?
      locale || best_locale_for_edition(edition)
    else
      I18n.default_locale
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
