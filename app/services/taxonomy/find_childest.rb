module Taxonomy
  class FindChildest
    attr_reader :tree, :selected_taxons

    def initialize(tree:, selected_taxons:)
      @tree = tree
      @selected_taxons = selected_taxons
    end

    def taxons
      tree.each_with_object([]) do |taxon, list_of_taxons|
        content_ids = taxon.descendants.map(&:content_id)

        any_descendants_selected = selected_taxons.any? do |selected_taxon|
          content_ids.include?(selected_taxon)
        end

        unless any_descendants_selected
          content_id = taxon.content_id
          list_of_taxons << content_id if selected_taxons.include?(content_id)
        end
      end
    end
  end
end
