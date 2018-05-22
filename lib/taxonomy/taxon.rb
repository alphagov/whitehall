# This has been copied into Content Tagger, pending a decision on where it should live.
# If you're changing it, please consider handling the common case.
module Taxonomy
  class Taxon
    extend Forwardable
    attr_reader :name, :content_id, :base_path, :phase, :visible_to_departmental_editors, :legacy_mapping
    attr_accessor :parent_node, :children
    def_delegators :taxon_list, :map, :each

    def initialize(title:, base_path:, content_id:, phase: 'live', visible_to_departmental_editors: true, legacy_mapping:)
      @name = title
      @content_id = content_id
      @base_path = base_path
      @phase = phase
      @visible_to_departmental_editors = visible_to_departmental_editors
      @children = []
      @legacy_mapping = legacy_mapping
    end

    def taxon_list
      @_taxon_list ||= children.each_with_object([self]) do |child, tree|
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

    def count
      taxon_list.count
    end

    def root?
      parent_node.nil?
    end

    def node_depth
      return 0 if root?
      1 + parent_node.node_depth
    end
  end
end
