module Taxonomy
  EDUCATION_CONTENT_ID = "c58fdadd-7743-46d6-9629-90bb3ccc4ef0".freeze

  def self.education
    content_item = Whitehall.publishing_api_v2_client.get_content(EDUCATION_CONTENT_ID)
    expanded_links = Whitehall.publishing_api_v2_client.get_expanded_links(EDUCATION_CONTENT_ID)

    parser = PublishingApiLinkedEditionParser.new(content_item)
    parser.add_expanded_links(expanded_links)
    parser.linked_edition
  end

  # TODO: move this to a gem
  # https://github.com/alphagov/govuk_taxonomy_helpers/pull/1
  class LinkedEdition
    extend Forwardable
    attr_reader :name, :content_id, :base_path
    attr_accessor :parent_node
    def_delegators :tree, :map, :each

    def initialize(name:, base_path:, content_id:)
      @name = name
      @content_id = content_id
      @base_path = base_path
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
        base_path: edition_response["base_path"]
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
        base_path: nested_item["base_path"]
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
