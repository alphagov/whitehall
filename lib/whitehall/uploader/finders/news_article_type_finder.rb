class Whitehall::Uploader::Finders::NewsArticleTypeFinder
  SPECIAL_CASES = {
    '' => NewsArticleType::ImportedAwaitingType
  }

  def self.find(slug, logger, line_number)
    slug ||= ''
    type = NewsArticleType.find_by_slug(slug) || SPECIAL_CASES[slug]
    error_message = "Unable to find News article type with slug '#{slug}' try one of (#{NewsArticleType.all_slugs})"
    logger.error(error_message, line_number) unless type
    type
  end
end
