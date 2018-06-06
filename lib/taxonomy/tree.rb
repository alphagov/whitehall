# This has been copied into Content Tagger, pending a decision on
# where it should live.  If you're changing it, please consider
# handling the common case.

# Recursive parser for publishing-api Taxon data
module Taxonomy
  class Tree
    attr_reader :root_taxon

    def initialize(expanded_root_taxon_hash)
      @root_taxon = Taxon.from_taxon_hash(expanded_root_taxon_hash)
      root_taxon.children = parse_taxons(
        root_taxon,
          expanded_root_taxon_hash['expanded_links_hash']
      )
    end

  private

    def parse_taxons(parent, item_hash)
      child_nodes(item_hash).map do |child|
        Taxon.from_taxon_hash(child).tap do |taxon|
          taxon.parent_node = parent
          taxon.children = parse_taxons(taxon, child)
        end
      end
    end

    def child_nodes(item_hash)
      children = item_hash.dig('links', 'child_taxons') ||
        item_hash.dig('expanded_links', 'child_taxons') || []
      children.sort_by { |hsh| hsh.fetch('title') }
    end
  end
end
