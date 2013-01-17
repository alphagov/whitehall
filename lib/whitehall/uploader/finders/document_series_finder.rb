class Whitehall::Uploader::Finders::DocumentSeriesFinder
  def self.find(*slugs, logger, line_number)
    slugs = slugs.reject { |slug| slug.blank? }.uniq
    slugs.collect do |slug|
      if document_series = DocumentSeries.find_by_slug(slug)
        document_series
      else
        logger.error "Unable to find Document series with slug '#{slug}'"
        nil
      end
    end.compact
  end
end
