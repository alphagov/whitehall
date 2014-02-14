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
    model_type = "#{@edition.type.underscore}_type".to_sym
    @edition.respond_to?(model_type) ? @edition.send(model_type).key : @edition.type.underscore
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
