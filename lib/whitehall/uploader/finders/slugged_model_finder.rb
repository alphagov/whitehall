class Whitehall::Uploader::Finders::SluggedModelFinder
  def initialize(klass)
    @klass = klass
  end

  def find(*slugs, logger, line_number)
    slugs = slugs.reject { |slug| slug.blank? }.uniq
    slugs.collect do |slug|
      @klass.find_by_slug(slug) || begin
        logger.error "Unable to find Topic with slug '#{slug}'"
        nil
      end
    end.compact
  end
end