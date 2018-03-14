module Taxonomy
  class GovukTaxonomy
    def initialize(adapter: RedisCacheAdapter.new, tree_builder_class: Tree)
      @adapter = adapter
      @tree_builder_class = tree_builder_class
    end

    def live
      @_live ||= branches.select do |level_one_taxon|
        level_one_taxon.phase == 'live' && level_one_taxon.visible_to_departmental_editors
      end
    end

    def alpha_beta
      @_alpha_beta ||= branches.select do |level_one_taxon|
        level_one_taxon.phase != 'live' && level_one_taxon.visible_to_departmental_editors
      end
    end

    def all_taxons
      @_taxon_list ||= branches.flat_map(&:taxon_list)
    end

    def visible_taxons
      @_visible_taxons = all_taxons.select(&:visible_to_departmental_editors)
    end

    def matching_against_published_taxons(taxons)
      matching_against_taxonomy_branches(taxons, children)
    end

    def matching_against_visible_draft_taxons(taxons)
      matching_against_taxonomy_branches(taxons, draft_child_taxons)
    end

    private

    def matching_against_taxonomy_branches(taxons, taxonomy_branches)
      taxonomy_branches.flat_map do |branch|
        filter_against_taxonomy_branch(taxons, branch)
      end
    end

    def filter_against_taxonomy_branch(selected_taxons_content_ids, taxon)
      matched_taxons = []

      if selected_taxons_content_ids.include?(taxon.content_id)
        matched_taxons << taxon.content_id
      end

      taxon.children.each do |child_taxon_branch|
        matched_taxons.concat(filter_against_taxonomy_branch(selected_taxons_content_ids, child_taxon_branch))
      end

      matched_taxons
    end

    def branches
      @_branches ||= @adapter.taxon_data.map do |taxon_hash|
        @tree_builder_class.new(taxon_hash).root_taxon
      end
    end

  end
end
