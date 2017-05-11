module Taxonomy
  class GovukTaxonomy
    def initialize(adapter: PublishingApiAdapter.new, tree_builder_class: Tree)
      @adapter = adapter
      @tree_builder_class = tree_builder_class
    end

    def children
      @_children ||= begin
        @adapter.published_taxon_data
          .map { |taxon_hash| build_tree(taxon_hash) }
      end
    end

    def draft_child_taxons
      @_draft_child_taxons ||= begin
        @adapter.draft_taxon_data
          .select { |taxon_hash| visible_to_departmental_editors?(taxon_hash) }
          .map { |taxon_hash| build_tree(taxon_hash) }
      end
    end

    def all_taxons
      @_all_taxons ||= children.flat_map(&:tree) + draft_child_taxons.flat_map(&:tree)
    end

  private

    def visible_to_departmental_editors?(taxon_hash)
      taxon_hash.fetch('details', {})['visible_to_departmental_editors']
    end

    def build_tree(taxon_hash)
      tree_data = @adapter.tree_data(taxon_hash['content_id'])
      taxon_hash['expanded_links_hash'] = tree_data
      @tree_builder_class.new(taxon_hash).root_taxon
    end
  end
end
