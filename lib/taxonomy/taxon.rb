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

    def self.from_taxon_hash(taxon_hash)
      taxon = Taxon.new(
        title: taxon_hash['title'],
        base_path: taxon_hash['base_path'],
        content_id: taxon_hash['content_id'],
        phase: taxon_hash['phase'],
        visible_to_departmental_editors: !!taxon_hash.dig(
          'details', 'visible_to_departmental_editors'
        ),
        legacy_mapping: legacy_mapping(taxon_hash)
      )

      parent_taxons = taxon_hash.dig("links", "parent_taxons")
      if parent_taxons.present?
        # There should not be more than one parent for a taxon. If there is,
        # pick the first one.
        taxon.parent_node = from_taxon_hash(parent_taxons.first)
      end

      taxon
    end

    def self.legacy_mapping(taxon_hash)
      legacy_taxon_links = taxon_hash.dig('links', 'legacy_taxons') || []

      legacy_taxon_links.each do |legacy_page|
        # Dealing with placeholders is a pain, so pretend everything
        # is not a placeholder
        legacy_page['document_type'] =
          legacy_page['document_type'].remove("placeholder_")
      end

      # Because the different types of legacy taxon (policy, policy
      # area, specialist topic) need to be handled differently,
      # separate them out by document type here
      legacy_taxon_links.group_by do |legacy_page|
        legacy_page['document_type']
      end
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
