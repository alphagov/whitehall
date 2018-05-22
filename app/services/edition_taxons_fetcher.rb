class EditionTaxonsFetcher
  attr_accessor :content_id

  def initialize(content_id)
    @content_id = content_id
  end

  def fetch
    taxons.select do |taxon|
      visible?(taxon) && topic_taxon?(taxon.content_id)
    end
  end

  def fetch_world_taxons
    taxons.select do |taxon|
      visible?(taxon) && world_taxon?(taxon.content_id)
    end
  end

private

  def taxons
    @_taxons ||= taxon_links.map { |taxon_link| build_taxon(taxon_link) }
  end

  def visible?(taxon)
    taxon.parent_node.nil? ? taxon.visible_to_departmental_editors : visible?(taxon.parent_node)
  end

  def topic_taxon?(content_id)
    !world_taxon?(content_id)
  end

  def world_taxon?(content_id)
    world_taxon_content_ids = all_world_taxons.map(&:content_id)
    content_id.in?(world_taxon_content_ids)
  end

  def build_taxon(taxon_link)
    taxon = Taxonomy::Taxon.new(
      title: taxon_link['title'],
      base_path: taxon_link['base_path'],
      content_id: taxon_link['content_id'],
      phase: taxon_link['phase'],
      visible_to_departmental_editors: !!taxon_link.dig('details', 'visible_to_departmental_editors'),
      legacy_mapping: legacy_mapping(taxon_link)
    )

    parent_taxons = taxon_link.dig("links", "parent_taxons")
    if parent_taxons.present?
      # There should not be more than one parent for a taxon. If there is,
      # pick the first one.
      taxon.parent_node = build_taxon(parent_taxons.first)
    end

    taxon
  end

  def legacy_mapping(taxon_hash)
    (taxon_hash.dig('links', 'legacy_taxons') || []).group_by do |legacy_page|
      legacy_page['document_type']
    end
  end

  def taxon_links
    response["expanded_links"].fetch("taxons", [])
  rescue GdsApi::HTTPNotFound
    []
  end

  def response
    Services.publishing_api.get_expanded_links(content_id)
  end

  def all_world_taxons
    Taxonomy::WorldTaxonomy.new.all_world_taxons.flat_map(&:taxon_list)
  end
end
