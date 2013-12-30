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
module LocalisedRoutingPatch
  LOCALE_REGEX = Regexp.compile(Locale.non_english.map(&:code).join("|"))

  attr_reader :localise_routing

  def initialize(set, scope, path, options)
    @localise_routing = options.delete(:localised)
    super(set, scope, path, options)
  end

  def normalize_requirements!
    super
    if localise_routing?
      @requirements[:locale] = LOCALE_REGEX
    end
  end

  def normalize_defaults!
    super
    if localise_routing?
      @defaults[:locale] = I18n.default_locale.to_s
    end
  end

  def normalize_path!
    if localise_routing?
      @path = "#{@path}(.:locale)"
    end
    super
  end

  def localise_routing?
    @localise_routing
  end
end

class ActionDispatch::Routing::Mapper::Mapping
  prepend LocalisedRoutingPatch
end
