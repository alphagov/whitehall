module Taxonomy
  EDUCATION_CONTENT_ID = "c58fdadd-7743-46d6-9629-90bb3ccc4ef0".freeze
  DRAFT_CONTENT_IDS = ["a544d48b-1e9e-47fb-b427-7a987c658c14", "206b7f3a-49b5-476f-af0f-fd27e2a68473"].freeze

  def self.drafts
    DRAFT_CONTENT_IDS.map do |content_id|
      content_item = Services.publishing_api.get_content(content_id)
      expanded_links = Services.publishing_api.get_expanded_links(content_id, with_drafts: true)

      parser = PublishingApiLinkedEditionParser.new(content_item)
      parser.add_expanded_links(expanded_links)
      parser.linked_edition
    end
  end

  def self.education
    content_item = Services.publishing_api.get_content(EDUCATION_CONTENT_ID)
    expanded_links = Services.publishing_api.get_expanded_links(EDUCATION_CONTENT_ID, with_drafts: false)

    parser = PublishingApiLinkedEditionParser.new(content_item)
    parser.add_expanded_links(expanded_links)
    parser.linked_edition
  end

  # TODO: move this to a gem
  # https://github.com/alphagov/govuk_taxonomy_helpers
  class LinkedEdition
    extend Forwardable
    attr_reader :name, :content_id, :base_path, :draft
    attr_accessor :parent_node
    def_delegators :tree, :map, :each

    def initialize(name:, base_path:, content_id:, draft:)
      @name = name
      @content_id = content_id
      @base_path = base_path
      @draft = draft
      @children = []
    end

    def children
      @children.sort_by(&:name)
    end

    def <<(child_node)
      child_node.parent_node = self
      @children << child_node
    end

    def tree
      return [self] if @children.empty?

      @children.each_with_object([self]) do |child, tree|
        tree.concat(child.tree)
      end
    end

    def descendants
      tree.tap(&:shift)
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

    def count
      tree.count
    end

    def root?
      parent_node.nil?
    end

    def node_depth
      return 0 if root?
      1 + parent_node.node_depth
    end
  end

  class PublishingApiLinkedEditionParser
    attr_accessor :linked_edition

    def initialize(edition_response, name_field: "title")
      @linked_edition = LinkedEdition.new(
        name: edition_response[name_field],
        content_id: edition_response["content_id"],
        base_path: edition_response["base_path"],
        draft: edition_response["draft"]
      )

      @name_field = name_field
    end

    def add_expanded_links(expanded_links_response)
      child_taxons = expanded_links_response["expanded_links"]["child_taxons"]

      if child_taxons.present?
        child_taxons.each do |child|
          linked_edition << parse_nested_item(child)
        end
      end
    end

  private

    attr_reader :name_field

    def parse_nested_item(nested_item)
      nested_linked_edition = LinkedEdition.new(
        name: nested_item[name_field],
        content_id: nested_item["content_id"],
        base_path: nested_item["base_path"],
        draft: nested_item["draft"]
      )

      child_taxons = nested_item["links"]["child_taxons"]

      if child_taxons.present?
        child_taxons.each do |child|
          nested_linked_edition << parse_nested_item(child)
        end
      end

      nested_linked_edition
    end
  end
end
