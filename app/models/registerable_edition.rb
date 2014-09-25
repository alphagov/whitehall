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
    panopticon_slug = Whitehall.url_maker.public_document_path(edition).sub(/\A\//, "")
    if edition.deleted?
      panopticon_slug.sub!(%r{/deleted-([^/]+)$}, '/\1')
    end
    panopticon_slug
  end

  def paths
    if kind == "detailed_guide"
      [base_path]
    else
      []
    end
  end

  def base_path
    "/#{slug}"
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
    if no_longer_published?
      "archived"
    elsif published?
      "live"
    else
      "draft"
    end
  end

  def need_ids
    edition.need_ids
  end

  def specialist_sectors
    [edition.primary_specialist_sector_tag].compact + edition.secondary_specialist_sector_tags
  end

  def organisation_ids
    registered_organisations.map(&:slug)
  end

  def registered_organisations
    if edition.respond_to?(:organisations)
      edition.organisations.reject {|organisation| organisation.is_a?(WorldwideOrganisation) }
    else
      []
    end
  end

  def attributes_for_publishing_api
    {
      title: title,
      base_path: base_path,
      description: description,
      format: "placeholder", # This will be updated once Whitehall uses the Content Store permanently
      need_ids: need_ids,
      public_updated_at: edition.public_timestamp,
      publishing_app: "whitehall",
      rendering_app: "whitehall-frontend",
      routes: [ { path: base_path, type: "exact" } ], # Placeholder does not register routes but still needs to send the base path.
      redirects: [],
      update_type: update_type,
      details: {
        change_note: latest_change_note,
        tags: {
          browse_pages: [],
          topics: specialist_sectors, # This will appear as a top-level section later on.
        }
      }
    }
  end

  def latest_change_note
    edition.most_recent_change_note
  end

  def update_type
    if edition.minor_change?
      "minor"
    else
      "major"
    end
  end

private

  def no_longer_published?
    (edition.state == "archived" || edition.state == "deleted") || edition.unpublishing != nil
  end

  def published?
    edition.state == "published"
  end
end
