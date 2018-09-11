module Taxonomy
  class TopicTaxonomy
    def initialize(adapter: RedisCacheAdapter.new, tree_builder_class: Tree)
      @adapter = adapter
      @tree_builder_class = tree_builder_class
    end

    def ordered_taxons
      @ordered_taxons ||= ordered_branches.select(&:visible_to_departmental_editors)
    end

    def all_taxons
      @all_taxons ||= branches.flat_map(&:taxon_list)
    end

    def visible_taxons
      @visible_taxons = all_taxons.select(&:visible_to_departmental_editors)
    end

  private

    def branches
      @branches ||= @adapter.taxon_data.map do |taxon_hash|
        @tree_builder_class.new(taxon_hash).root_taxon
      end
    end

    def ordered_branches
      @ordered_branches ||= branches.sort_by(&:name)
    end
  end
end
