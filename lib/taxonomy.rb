require 'taxonomy/taxon'
require 'taxonomy/publishing_api_linked_edition_parser'

module Taxonomy
  HOMEPAGE_CONTENT_ID = "f3bbdec2-0e62-4520-a7fd-6ffd5d36e03a".freeze
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

  def self.root_taxons
    @_root_taxons ||= begin
      Services.publishing_api
        .get_expanded_links(HOMEPAGE_CONTENT_ID, with_drafts: false)
        .to_h['expanded_links']
        .fetch('root_taxons', [])
        .map { |taxon_hash| Taxon.new(taxon_hash.symbolize_keys) }
    end
  end

  def self.all_taxonomy_trees
    root_taxons.map { |root_taxon| Taxonomy::Tree.new(root_taxon).root_taxon }
  end
end
