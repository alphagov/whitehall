class Whitehall::Uploader::Finders::SluggedModelFinder
  def initialize(klass, logger, line_number)
    @klass = klass
    @logger = logger
    @line_number = line_number
  end

  def find(slugs)
    slugs = slugs.reject { |slug| slug.blank? }.uniq
    slugs.collect do |slug|
      @klass.find_by_slug(slug) || begin
        @logger.error "Unable to find #{@klass.name} with slug '#{slug}'", @line_number
        nil
      end
    end.compact
  end
end
