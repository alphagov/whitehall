class Whitehall::Uploader::Finders::OrganisationFinder
  def self.find(name_or_slug, logger, line_number, default_organisation)
    return [default_organisation] if name_or_slug.blank?
    organisation = Organisation.find_by_name(name_or_slug) || Organisation.find_by_slug(name_or_slug)
    logger.error "Unable to find Organisation named '#{name_or_slug}'", line_number unless organisation
    [organisation].compact
  end
end
