class EmailSignup::InvalidSlugError < StandardError
  attr_accessor :slug, :attribute
  def initialize(slug, attribute)
    super("#{attribute} slug ('#{slug}') does not refer to an instance.")
    @slug = slug
    @attribute = attribute
  end
end
