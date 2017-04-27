module Taxonomy
  module PublishingApiRootTaxonParser
    def self.parse_taxons(item_hash, key: 'expanded_links')
      child_nodes(item_hash, key).map do |child|
        taxon = build_taxon(child)

        parse_taxons(child, key: 'links').each do |child_taxon|
          taxon.children << child_taxon
        end

        taxon
      end
    end

    private_class_method def self.child_nodes(item_hash, key)
      item_hash.fetch(key, {}).fetch("child_taxons", [])
    end

    private_class_method def self.build_taxon(item_hash)
      Taxon.new(
        name: item_hash["title"],
        content_id: item_hash["content_id"],
        base_path: item_hash["base_path"]
      )
    end
  end
end
