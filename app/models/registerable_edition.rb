class RegisterableEdition
  attr_accessor :edition

  def initialize(edition)
    @edition = edition
  end

  def ==(other)
    edition == other.edition
  end

  def slug
    # strip the preceding slash character from the generated slug,
    # to be consistent with Panopticon's slug format.
    Whitehall.url_maker.public_document_path(edition).sub(/\A\//,"")
  end

  def paths
    if kind == "detailed_guide"
      ["/#{slug}"]
    else
      []
    end
  end

  def prefixes
    []
  end

  def title
    edition.title
  end

  def description
    edition.summary
  end

  def kind
    model_type = "#{edition.type.underscore}_type".to_sym
    edition.respond_to?(model_type) ? edition.send(model_type).key : edition.type.underscore
  end

  def state
    edition.state == "published" ? "live" : "draft"
  end

  def specialist_sectors
    [edition.primary_specialist_sector_tag].compact + edition.secondary_specialist_sector_tags
  end

  def organisation_ids
    return [] unless edition.respond_to?(:organisations)

    edition.organisations.pluck(:slug)
  end
end
