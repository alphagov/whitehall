class Whitehall::Uploader::Finders::SpeechTypeFinder
  SPECIAL_CASES = {
    '' => SpeechType::ImportedAwaitingType
  }

  def self.find(slug, logger, line_number)
    slug ||= ''
    type = SpeechType.find_by_slug(slug) || SPECIAL_CASES[slug]
    logger.error "Unable to find Speech type with slug '#{slug}'" unless type
    type
  end
end
