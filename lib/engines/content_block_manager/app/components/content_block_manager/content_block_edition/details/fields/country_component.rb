class ContentBlockManager::ContentBlockEdition::Details::Fields::CountryComponent < ContentBlockManager::ContentBlockEdition::Details::Fields::EnumComponent
  BLANK_OPTION = "United Kingdom".freeze

  def initialize(**args)
    countries = WorldLocation.geographical.map(&:name)
    super(**args.merge(enum: countries))
  end

private

  def enum
    @enum.excluding(blank_option)
  end

  def blank_option
    BLANK_OPTION
  end
end
