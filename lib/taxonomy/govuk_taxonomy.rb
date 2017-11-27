module Taxonomy
  class GovukTaxonomy
    def initialize(adapter: RedisCacheAdapter.new, tree_builder_class: Tree)
      @adapter = adapter
      @tree_builder_class = tree_builder_class
    end

    def children
      @_children ||= begin
        @adapter.published_taxon_data.map { |taxon_hash| build_tree(taxon_hash) }
      end
    end

    def draft_child_taxons
      @_draft_child_taxons ||= begin
        @adapter.draft_taxon_data.map { |taxon_hash| build_tree(taxon_hash) }
      end
    end

    def all_taxons
      @_all_taxons ||= children.flat_map(&:tree) + draft_child_taxons.flat_map(&:tree)
    end

    def matching_against_published_taxons(taxons)
      @_published_taxons ||= matching_against_taxonomy_branches(taxons, children)
    end

    def matching_against_visible_draft_taxons(taxons)
      @_draft_visible_taxons ||= matching_against_taxonomy_branches(taxons, draft_child_taxons)
    end

  private

    def build_tree(taxon_hash)
      @tree_builder_class.new(taxon_hash).root_taxon
    end

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
  end
end
