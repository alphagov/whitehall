module Admin::WorldLocationHelper
  def world_location_tabs(world_location)
    tabs = {
      "Details" => admin_world_location_path(world_location),
      "Translations" => admin_world_location_translations_path(world_location),
      "Features (#{Locale.new(:en).native_language_name})" => features_admin_world_location_path(world_location, locale: I18n.default_locale)
    }
    world_location.non_english_translated_locales.each do |locale|
      tabs["Features (#{locale.native_language_name})"] = features_admin_world_location_path(world_location, locale: locale.code)
    end
    tabs
  end
end
