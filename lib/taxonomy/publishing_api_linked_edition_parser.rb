module Taxonomy
  class PublishingApiLinkedEditionParser
    attr_accessor :linked_edition

    def initialize(edition_response)
      @linked_edition = Taxon.new(edition_response.to_h.symbolize_keys)
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
      nested_linked_edition = Taxon.new(nested_item.symbolize_keys)

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
