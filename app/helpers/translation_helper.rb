module TranslationHelper
  def sorted_locales(locale_codes)
    locale_codes.sort_by { |c| c.to_s }.tap do |codes|
      codes.unshift(I18n.default_locale) if codes.delete(I18n.default_locale)
    end
  end

  def t_world_location(world_location)
    t("world_location.type.#{world_location.display_type_key}", count: 1)
  end

  def t_display_type(document, count = 1)
    t("document.type.#{document.display_type_key}", count: count)
  end

  def t_see_all_our(type)
    t("see_all.#{type}")
  end

  def t_delivered_on(speech_type)
    I18n.t("document.speech.#{speech_type.published_externally_key}")
  end

  def t_corporate_information_page_type(page)
    t("corporate_information_page.type.#{page.display_type_key}")
  end

  def t_corporate_information_page_link(organisation, slug)
    page = organisation.corporate_information_pages.for_slug(slug)
    page.extend(UseSlugAsParam)
    link_to(t_corporate_information_page_type(page), [organisation, page])
  end
end
