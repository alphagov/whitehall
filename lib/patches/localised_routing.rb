# This patches rails standard routing to make it easy to generate
# localised routes.  By adding the localised: true option to a
# rails route or resource, a :locale will be added before the
# :format parameter, i.e:
#
#     resource :documents, only: [:index], localised: true
#
# Will generate a route that matches:
#
#     /documents => {locale: 'en'}
#     /documents.fr => {locale: 'fr'}
#     /documents.json => {locale: 'en', format: 'json'}
#     /documents.fr.json => {locale: 'fr', format: 'json'}

# class ActionDispatch::Routing::Mapper::Mapping
#   LOCALE_REGEX = Regexp.compile(Locale.non_english.map(&:code).join("|"))

#   def localise_routing?
#     @localise_routing ||= @options.delete(:localised)
#   end

#   def normalize_path_with_locale(path)
#     if localise_routing?
#       normalize_path_without_locale "#{path}(.:locale)"
#     else
#       normalize_path_without_locale path
#     end
#   end

#   def requirements_with_locale
#     @requirements_with_locale ||= requirements_without_locale.tap do |r|
#       if localise_routing?
#         r[:locale] = LOCALE_REGEX
#       end
#     end
#   end

#   def defaults_with_locale
#     @defaults_with_locale ||= defaults_without_locale.tap do |d|
#       if localise_routing?
#         d[:locale] = I18n.default_locale.to_s
#       end
#     end
#   end

#   alias normalize_path_without_locale normalize_path
#   alias normalize_path normalize_path_with_locale

#   alias requirements_without_locale requirements
#   alias requirements requirements_with_locale

#   alias defaults_without_locale defaults
#   alias defaults defaults_with_locale
# end
