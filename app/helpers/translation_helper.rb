module TranslationHelper
  def sorted_locales(locale_codes)
    locale_codes.sort_by(&:to_s).tap do |codes|
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

  def t_delivery_title(document)
    if document.delivered_by_minister?
      t("document.speech.#{document.speech_type.owner_key_group}.minister")
    else
      t("document.speech.#{document.speech_type.owner_key_group}.speaker")
    end
  end

  def t_delivered_on(speech_type)
    I18n.t("document.speech.#{speech_type.published_externally_key}")
  end

  def t_corporate_information_page_type_link_text(page)
    if I18n.exists?("corporate_information_page.type.link_text.#{page.display_type_key}")
      t("corporate_information_page.type.link_text.#{page.display_type_key}")
    else
      t("corporate_information_page.type.title.#{page.display_type_key}")
    end
  end

  def t_corporate_information_page_link(organisation, slug)
    page = organisation.corporate_information_pages.for_slug(slug)
    page.extend(UseSlugAsParam)
    link_to(t_corporate_information_page_type_link_text(page), [organisation, page])
  end
end
