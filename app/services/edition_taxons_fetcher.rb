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
    @taxons ||= taxon_links.map { |taxon_link| Taxonomy::Taxon.from_taxon_hash(taxon_link) }
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
