class Whitehall::Uploader::Finders::EditionFinder < Whitehall::Uploader::Finders::SluggedModelFinder
  def find(*slugs)
    slugs = slugs.reject { |slug| slug.blank? }.uniq
    slugs.collect do |slug|
      if document = Document.where(document_type: @klass.name).find_by_slug(slug)
        if document.published_edition
          document.published_edition
        elsif document.latest_edition
          document.latest_edition
        end
      else
        @logger.error "Unable to find #{@klass.name} with slug '#{slug}'", @line_number
        nil
      end
    end.compact
  end
end
