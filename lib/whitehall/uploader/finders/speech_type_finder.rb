class Whitehall::Uploader::Finders::SpeechTypeFinder
  SPECIAL_CASES = {
  }

  def self.find(slug, logger, line_number)
    type = SpeechType.find_by_slug(slug) || SPECIAL_CASES[slug]
    logger.warn "Row #{line_number}: Unable to find Speech type with slug '#{slug}'" unless type
    type
  end
end
