class RegisterableEdition
  def initialize(edition)
    @edition = edition
  end

  def slug
    @edition.slug
  end

  def title
    @edition.title
  end

  def description
    @edition.summary
  end

  def kind
    @edition.type.underscore
  end

  def state
    @edition.state == "published" ? "live" : "draft"
  end

  def industry_sectors
    return [] unless @edition.is_a?(DetailedGuide)

    # check if there's any mainstream categories which match industry sector tags
    # if so, build a tag id and push them to Panopticon.
    @edition.mainstream_categories.select {|category|
      category.parent_tag == "oil-and-gas"
    }.map {|category|
      category.slug.sub(/\Aindustry-sector-oil-and-gas-/, 'oil-and-gas/')
    }
  end
end
