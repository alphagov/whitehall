module Taxonomy
  class WorldTaxonomy
    def initialize(adapter: RedisCacheAdapter.new, tree_builder_class: Tree)
      @adapter = adapter
      @tree_builder_class = tree_builder_class
    end

    def all_world_taxons
      @all_world_taxons ||= sorted_world_taxons
    end

    def all_world_taxons_transformed(selected_taxon_content_ids = [])
      transform_taxon(all_world_taxons, selected_taxon_content_ids)
    end

  private

    def sorted_world_taxons
      world_taxon_branches.sort_by do |world_taxon|
        [world_taxon.children.count.zero? ? 0 : 1, world_taxon.name]
      end
    end

    def transform_taxon(taxons, selected_taxon_content_ids)
      taxons.map do |taxon|
        {
          label: taxon.name,
          value: taxon.content_id,
          items: (transform_taxon(taxon.children, selected_taxon_content_ids) if taxon.children),
          checked: selected_taxon_content_ids.include?(taxon.content_id),
        }
      end
    end

    def world_taxon_branches
      @world_taxon_branches ||= @adapter.world_taxon_data.map do |world_taxon_hash|
        @tree_builder_class.new(world_taxon_hash).root_taxon
      end
    end
  end
end
