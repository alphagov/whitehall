# This module is used to patch the standard Rails routing to make it easy to
# generate localised routes in the format we want.  By adding the
# `localised: true` option to a  rails route or resource, a :locale compontent
# is added to the routing before the :format component, for example:
#
#   resource :documents, only: [:index], localised: true
#
# This generates the following routes:
#
#     /documents => {locale: 'en'}
#     /documents.fr => {locale: 'fr'}
#     /documents.json => {locale: 'en', format: 'json'}
#     /documents.fr.json => {locale: 'fr', format: 'json'}
#
module LocalisedMappingPatch
  VALID_LOCALES_REGEX = Regexp.compile(Locale.non_english.map(&:code).join("|"))

private

  # Add the optional :locale component to the path for localised routes. This is
  # done first as calling `super` may add the :format component to the end.
  def normalize_path!
    if localised_routing?
      @path = "#{path}(.:locale)"
    end

    super
  end

  # Add the default locale to the routing defaults for any localised routes.
  # This will default :locale to 'en' if it isn't explicitly present.
  def normalize_defaults!
    super

    if localised_routing?
      @defaults[:locale] = I18n.default_locale.to_s
    end
  end

  # Add requirements for localised routes such that :locale must be one of
  # the valid locales.
  def normalize_requirements!
    super

    if localised_routing?
      @requirements[:locale] = VALID_LOCALES_REGEX
    end
  end

  def localised_routing?
    @localise_routing ||= @options.delete(:localised)
  end
end

ActionDispatch::Routing::Mapper::Mapping.send(:prepend, LocalisedMappingPatch)
