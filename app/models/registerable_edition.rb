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

  def specialist_sectors
    return [] unless @edition.is_a?(DetailedGuide)

    @edition.specialist_sector_tags
  end
end
