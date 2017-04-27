module Taxonomy
  class PublishingApiLinkedEditionParser
    attr_accessor :linked_edition

    def initialize(edition_response, name_field: "title")
      @linked_edition = Taxon.new(
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
          linked_edition.children << parse_nested_item(child)
        end
      end
    end

  private

    attr_reader :name_field

    def parse_nested_item(nested_item)
      nested_linked_edition = Taxon.new(
        name: nested_item[name_field],
        content_id: nested_item["content_id"],
        base_path: nested_item["base_path"]
      )

      child_taxons = nested_item["links"]["child_taxons"]

      if child_taxons.present?
        child_taxons.each do |child|
          nested_linked_edition.children << parse_nested_item(child)
        end
      end

      nested_linked_edition
    end
  end
end
