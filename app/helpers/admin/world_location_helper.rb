module Admin::WorldLocationHelper
  def world_location_news_nav_items(world_location_instance, path)
    [
      {
        label: "Details",
        href: admin_world_location_news_path(world_location_instance),
        current: path == admin_world_location_news_path(world_location_instance),
      },
      {
        label: "Translations",
        href: admin_world_location_news_translations_path(world_location_instance),
        current: path == admin_world_location_news_translations_path(world_location_instance),
      },
      {
        label: "Features (#{Locale.new(:en).native_language_name})",
        href: features_admin_world_location_news_path(world_location_instance, locale: I18n.locale),
        current: path == features_admin_world_location_news_path(world_location_instance),
      },
      world_location_instance.non_english_translated_locales.map do |locale|
        {
          label: "Features (#{locale.native_language_name})",
          href: features_admin_world_location_news_path(world_location_instance, locale: locale.code),
          current: path == features_admin_world_location_news_path(world_location_instance, locale: locale.code),
        }
      end,
    ].flatten.compact
  end

  def world_location_news_tabs(world_location)
    tabs = {
      "Details" => admin_world_location_news_path(world_location),
      "Translations" => admin_world_location_news_translations_path(world_location),
      "Features (#{Locale.new(:en).native_language_name})" => features_admin_world_location_news_path(world_location, locale: I18n.default_locale),
    }
    world_location.non_english_translated_locales.each do |locale|
      tabs["Features (#{locale.native_language_name})"] = features_admin_world_location_news_path(world_location, locale: locale.code)
    end
    tabs
  end
end
