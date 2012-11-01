class Whitehall::Uploader::Finders::PoliciesFinder
  def self.find(*slugs, logger, line_number)
    slugs = slugs.reject { |slug| slug.blank? }.uniq
    slugs.collect do |slug|
      if document = Document.find_by_slug(slug)
        if document.published_edition
          document.published_edition
        elsif document.latest_edition
          document.latest_edition
        end
      else
        logger.warn "Row #{line_number}: Unable to find Document with slug '#{slug}'"
        nil
      end
    end.compact
  end
end