module Taxonomy
  class WorldTaxonomy
    def initialize(adapter: RedisCacheAdapter.new, tree_builder_class: Tree)
      @adapter = adapter
      @tree_builder_class = tree_builder_class
    end

    def all_world_taxons
      @_all_world_taxons ||= sorted_world_taxons
    end

  private

    def sorted_world_taxons
      world_taxon_branches.sort_by do |world_taxon|
        [world_taxon.children.count.zero? ? 0 : 1, world_taxon.name]
      end
    end

    def world_taxon_branches
      @_branches ||= @adapter.world_taxon_data.map do |world_taxon_hash|
        @tree_builder_class.new(world_taxon_hash).root_taxon
      end
    end
  end
end
