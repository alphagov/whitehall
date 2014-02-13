class RegisterableEdition
  def initialize(edition)
    @edition = edition
  end

  def slug
    # strip the preceding slash character from the generated slug,
    # to be consistent with Panopticon's slug format.
    routes_helper.public_document_path(@edition).sub(/\A\//,"")
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

  private

  def routes_helper
    @routes_helper ||= Whitehall::UrlMaker.new
  end
end
