class Whitehall::Uploader::Finders::DocumentSeriesFinder
  def self.find(slug, logger, line_number)
    return if slug.blank?
    document_series = DocumentSeries.find_by_slug(slug)
    logger.warn "Row #{line_number}: Unable to find Document series with slug '#{slug}'" unless document_series
    document_series
  end
end
