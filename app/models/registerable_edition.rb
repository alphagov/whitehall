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
    "live"
  end
end
