module TranslationHelper
  def t_lang(key, options = {})
    fallback = t_fallback(key, options)
    if fallback && fallback != I18n.locale
      "lang=#{fallback}"
    end
  end

  def t_fallback(key, options = {})
    translation = I18n.t(key, **options, locale: I18n.locale, fallback: false, default: "fallback")

    if !translation || translation.eql?("fallback")
      I18n.default_locale
    elsif translation.is_a? Hash
      translation.values.all?(&:nil?) ? I18n.default_locale : false
    else
      false
    end
  end

  def t_corporate_information_page_link(organisation, slug)
    page = organisation.corporate_information_pages.for_slug(slug)
    page.extend(UseSlugAsParam)
    link_to(t_corporate_information_page_type_link_text(page), page.public_path(locale:), class: "govuk-link")
  end
end
