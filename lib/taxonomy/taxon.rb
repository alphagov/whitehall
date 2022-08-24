# This has been copied into Content Tagger, pending a decision on where it should live.
# If you're changing it, please consider handling the common case.
module Taxonomy
  class Taxon
    attr_reader :name, :content_id, :base_path, :phase, :visible_to_departmental_editors
    attr_accessor :parent_node, :children

    delegate :map, :each, :count, to: :taxon_list

    def initialize(title:, base_path:, content_id:, phase: "live", visible_to_departmental_editors: true)
      @name = title
      @content_id = content_id
      @base_path = base_path
      @phase = phase
      @visible_to_departmental_editors = visible_to_departmental_editors
      @children = []
    end

    def self.from_taxon_hash(taxon_hash)
      taxon = Taxon.new(
        title: taxon_hash["title"],
        base_path: taxon_hash["base_path"],
        content_id: taxon_hash["content_id"],
        phase: taxon_hash["phase"],
        visible_to_departmental_editors: taxon_hash.dig(
          "details", "visible_to_departmental_editors"
        ).present?,
      )

      parent_taxons = taxon_hash.dig("links", "parent_taxons")
      if parent_taxons.present?
        # There should not be more than one parent for a taxon. If there is,
        # pick the first one.
        taxon.parent_node = from_taxon_hash(parent_taxons.first)
      end

      taxon
    end

    def taxon_list
      @taxon_list ||= children.each_with_object([self]) do |child, tree|
        tree.concat(child.taxon_list)
      end
    end

    def descendants
      taxon_list.tap(&:shift)
    end

    # Get ancestors of a taxon
    #
    # @return [Array] all taxons in the path from the root of the taxonomy to the parent taxon
    def ancestors
      if parent_node.nil?
        []
      else
        parent_node.ancestors + [parent_node]
      end
    end

    # Get a breadcrumb trail for a taxon
    #
    # @return [Array] all taxons in the path from the root of the taxonomy to this taxon
    def breadcrumb_trail
      ancestors + [self]
    end

    def full_path
      breadcrumb_trail.map { |t| { title: t.name } }
    end
  end
end
