require 'whitehall/uploader/finders'

class Whitehall::Uploader::Finders::OrganisationFinder
  def self.find(name_or_slug, logger, line_number)
    return [] if name_or_slug.blank?
    organisation = Organisation.find_by_name(name_or_slug) || Organisation.find_by_slug(name_or_slug)
    logger.warn "Row #{line_number}: Unable to find Organisation named '#{name_or_slug}'" unless organisation
    [organisation].compact
  end
end
