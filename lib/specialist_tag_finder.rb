class SpecialistTagFinder

  def initialize(edition)
    @edition = edition
  end

  def topics
    presented_edition = PublishingApiPresenters::Edition.new(@edition)
    edition_path = presented_edition.base_path
    content_item = Whitehall.content_store.content_item(edition_path)
    return [] unless content_item
    Array(content_item.links["topics"])
  end

  def grandparent_topic
    presented_edition = PublishingApiPresenters::Edition.new(@edition)
    edition_path = presented_edition.base_path
    edition_content_item = Whitehall.content_store.content_item(edition_path)
    return unless edition_content_item
    parents = Array(edition_content_item.links["parent"])
    return unless parents.any?

    # FIXME: We now need to fetch the parent topic from the content store to
    # retrieve its parent. We should replace this implementation with the
    # publishing API's links expansion / dependency resolution, which is
    # currently WIP.
    parent_path = parents.first["base_path"]
    parent_content_item = Whitehall.content_store.content_item(parent_path)
    Array(parent_content_item.links["parent"]).first
  end

  def primary_sector_tag
    primary_subsector_tag.parent if primary_subsector_tag
  end

  def primary_subsector_tag
    if (primary_tag_slug = @edition.primary_specialist_sector_tag)
      specialist_sector_tags.find {|t| t.slug == primary_tag_slug }
    end
  end

  def sectors_and_subsectors
    specialist_sector_tags.map { |t| [t, t.parent] }.flatten.compact.uniq
  end

private

  def artefact
    @artefact ||= Whitehall.content_api.artefact(RegisterableEdition.new(@edition).slug)
  end

  def specialist_sector_tags
    return [] if artefact.nil?
    artefact.tags.select {|t| t.details['type'] == 'specialist_sector' }
  end
end
