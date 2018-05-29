module Taxonomy
  class WorldTaxonomy
    def initialize(adapter: RedisCacheAdapter.new, tree_builder_class: Tree)
      @adapter = adapter
      @tree_builder_class = tree_builder_class
    end

    def all_world_taxons
      @_world_taxon_list ||= world_taxon_branches
    end

  private

    def world_taxon_branches
      @_branches ||= @adapter.world_taxon_data.map do |world_taxon_hash|
        @tree_builder_class.new(world_taxon_hash).root_taxon
      end
    end
  end
end
