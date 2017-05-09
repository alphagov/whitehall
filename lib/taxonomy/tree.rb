module Taxonomy
  class Tree
    attr_reader :root_taxon

    def initialize(root_taxon, expanded_links_hash)
      @root_taxon = root_taxon
      root_taxon.children = parse_taxons(expanded_links_hash)
    end

  private

    def parse_taxons(item_hash, key: 'expanded_links')
      child_nodes(item_hash, key).map do |child|
        taxon = Taxon.new(child.symbolize_keys)
        taxon.children = parse_taxons(child, key: 'links')
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
