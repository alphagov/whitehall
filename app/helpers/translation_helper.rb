module TranslationHelper
  def t_world_location(world_location)
    t("world_location.type.#{world_location.display_type_key}")
  end

  def t_display_type(document)
    t("document.type.#{document.display_type_key}").capitalize
  end

  def t_world_location_see_all_our(type)
    t("world_location.see_all", type: t("document.type.#{type}").pluralize)
  end
end
