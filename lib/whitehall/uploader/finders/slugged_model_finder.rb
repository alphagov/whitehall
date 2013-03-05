class Whitehall::Uploader::Finders::SluggedModelFinder
  def initialize(klass, logger)
    @klass = klass
    @logger = logger
  end

  def find(slugs)
    slugs = slugs.reject { |slug| slug.blank? }.uniq
    slugs.collect do |slug|
      @klass.find_by_slug(slug) || begin
        @logger.error "Unable to find #{@klass.name} with slug '#{slug}'"
        nil
      end
    end.compact
  end
end