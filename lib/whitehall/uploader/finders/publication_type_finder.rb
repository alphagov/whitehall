class Whitehall::Uploader::Finders::PublicationTypeFinder
  SPECIAL_CASES = {
    'Impact assessment' => PublicationType::ImpactAssessment,
    '' => PublicationType::ImportedAwaitingType
  }

  def self.find(slug, logger, line_number)
    slug ||= ''
    type = PublicationType.find_by_slug(slug) || SPECIAL_CASES[slug]
    logger.error "Unable to find Publication type with slug '#{slug}'", line_number unless type
    type
  end
end
