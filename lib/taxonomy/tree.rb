# Recursive parser for publishing-api Taxon data
module Taxonomy
  class Tree
    attr_reader :root_taxon

    def initialize(expanded_root_taxon_hash)
      @root_taxon = build_taxon(expanded_root_taxon_hash)
      root_taxon.children = parse_taxons(
        root_taxon,
        expanded_root_taxon_hash['expanded_links_hash']
      )
    end

  private

    def build_taxon(taxon_hash)
      Taxon.new taxon_hash.symbolize_keys.slice(:title, :base_path, :content_id)
    end

    def parse_taxons(parent, item_hash, key: 'expanded_links')
      child_nodes(item_hash, key).map do |child|
        taxon = build_taxon(child)
        taxon.parent_node = parent
        taxon.children = parse_taxons(taxon, child, key: 'links')
        taxon
      end
    end

    def child_nodes(item_hash, key)
      item_hash
        .fetch(key, {})
        .fetch('child_taxons', [])
        .sort_by { |hsh| hsh.fetch('title') }
    end
  end
end
