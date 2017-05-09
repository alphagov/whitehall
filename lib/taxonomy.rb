require 'taxonomy/taxon'

module Taxonomy
  HOMEPAGE_CONTENT_ID = "f3bbdec2-0e62-4520-a7fd-6ffd5d36e03a".freeze

  def self.draft_taxons
    all_homepage_taxons = Rails.cache.fetch("homepage-root-taxons-with-drafts", expires_in: 24.hours) do
      Services.publishing_api.get_expanded_links(HOMEPAGE_CONTENT_ID, with_drafts: true).to_h
    end

    all_homepage_taxons
      .fetch('expanded_links', {})
      .fetch('root_taxons', [])
      .reject { |taxon_hash| root_taxons.any? { |taxon| taxon.content_id == taxon_hash["content_id"] } }
      .select { |taxon_hash| taxon_hash.fetch('details', {})['visible_to_departmental_editors'] }
      .map { |taxon_hash| Taxon.new(taxon_hash.symbolize_keys) }
  end

  def self.root_taxons
    homepage_taxons = Rails.cache.fetch("homepage-root-taxons", expires_in: 24.hours) do
      Services.publishing_api.get_expanded_links(HOMEPAGE_CONTENT_ID, with_drafts: false).to_h
    end

    homepage_taxons
      .fetch('expanded_links', {})
      .fetch('root_taxons', [])
      .map { |taxon_hash| Taxon.new(taxon_hash.symbolize_keys) }
  end

  def self.load_taxonomy_trees(taxon_list)
    taxon_list.map do |root_taxon|
      expanded_links_hash = Rails.cache.fetch("taxonomy-tree-root-#{root_taxon.content_id}", expires_in: 1.hour) do
        Services.publishing_api.get_expanded_links(root_taxon.content_id, with_drafts: false).to_h
      end

      Taxonomy::Tree.new(root_taxon, expanded_links_hash).root_taxon
    end
  end
end
