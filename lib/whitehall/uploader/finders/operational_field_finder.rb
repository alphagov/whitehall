class Whitehall::Uploader::Finders::OperationalFieldFinder
  def self.find(name_or_slug, logger, line_number)
    return nil if name_or_slug.blank?
    operational_field = OperationalField.find_by_name(name_or_slug) || OperationalField.find_by_slug(name_or_slug)
    logger.error "Unable to find Field of Operation with name or slug '#{name_or_slug}'", line_number unless operational_field
    operational_field
  end
end
