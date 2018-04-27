module Taxonomy
  class TopicTaxonomy
    def initialize(adapter: RedisCacheAdapter.new, tree_builder_class: Tree)
      @adapter = adapter
      @tree_builder_class = tree_builder_class
    end

    def live
      @_live ||= branches.select do |level_one_taxon|
        level_one_taxon.phase == 'live' &&
          level_one_taxon.visible_to_departmental_editors
      end
    end

    def alpha_beta
      @_alpha_beta ||= branches.select do |level_one_taxon|
        level_one_taxon.phase != 'live' &&
          level_one_taxon.visible_to_departmental_editors
      end
    end

    def all_taxons
      @_taxon_list ||= branches.flat_map(&:taxon_list)
    end

    def visible_taxons
      @_visible_taxons = all_taxons.select(&:visible_to_departmental_editors)
    end

  private

    def branches
      @_branches ||= @adapter.taxon_data.map do |taxon_hash|
        @tree_builder_class.new(taxon_hash).root_taxon
      end
    end
  end
end
