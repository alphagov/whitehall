class Whitehall::Uploader::Finders::CountriesFinder
  def self.find(*slugs, logger, line_number)
    slugs = slugs.reject { |slug| slug.blank? }

    countries = slugs.map do |slug|
      country = Country.find_by_slug(slug)
      logger.error "Unable to find Country with slug '#{slug}'" unless country
      country
    end.compact
  end
end
