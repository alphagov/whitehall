class ContentBlockManager::ContentBlockEdition::Details::Fields::CountryComponent < ContentBlockManager::ContentBlockEdition::Details::Fields::EnumComponent
  def initialize(**args)
    countries = WorldLocation.geographical.map(&:name)
    super(**args.merge(enum: countries))
  end
end
