module TranslationHelper
  def t_world_location(world_location)
    t("world_location.type.#{world_location.display_type_key}", count: 1)
  end

  def t_display_type(document, count=1)
    translation = t("document.type.#{document.display_type_key}", count: count)
  end

  def t_world_location_see_all_our(type)
    t("world_location.see_all", type: t("document.type.#{type}", count: 2).downcase)
  end
end
