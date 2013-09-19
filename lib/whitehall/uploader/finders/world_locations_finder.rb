class Whitehall::Uploader::Finders::WorldLocationsFinder
  def self.find(*slugs, logger, line_number)
    slugs = slugs.reject { |slug| slug.blank? }

    world_locations = slugs.map do |slug|
      world_location = WorldLocation.find_by_slug(slug)
      logger.error "Unable to find WorldLocation with slug '#{slug}'", line_number unless world_location
      world_location
    end.compact
  end
end
