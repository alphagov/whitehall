module TranslationsForAssociations
  # This is to allow us to do eager loading on translations for
  # associated objects (e.g. load all document collection and their orgs
  # including the translations for the orgs).
  # Don't know why
  #   DocumentCollection.includes(organisation: :translations).
  #     merge(Organisation.with_translations)
  # doesn't work; it gives:
  #   ActiveRecord::ConfigurationError: Association named 'translations' was not found; perhaps you misspelled it?
  # so we do everything that scope (from globalize3) does, but by hand
  def with_translations_for(association, *locales)
    association_class = reflections[association].klass
    translation_class = association_class.translation_class
    locales = translation_class.translated_locales if locales.empty?
    includes(association => :translations).
      merge(translation_class.with_locales(locales)).
      merge(association_class.with_required_attributes)
  end
end

# Make our scope for eager-loading translated associations available to
# all models
ActiveRecord::Base.extend(TranslationsForAssociations)
