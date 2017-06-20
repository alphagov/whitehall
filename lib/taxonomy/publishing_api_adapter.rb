module Taxonomy
  class PublishingApiAdapter
    HOMEPAGE_CONTENT_ID = "f3bbdec2-0e62-4520-a7fd-6ffd5d36e03a".freeze

    def draft_taxon_data
      @_draft_data ||= begin
        taxons = all_taxon_data_including_draft - published_taxon_data
        expand_taxon_array only_visible_taxons(taxons)
      end
    end

    def published_taxon_data
      @_published_data ||= begin
        taxons = get_root_taxons(with_drafts: false)
        expand_taxon_array(taxons)
      end
    end

  private

    def only_visible_taxons(taxons)
      taxons.select { |taxon_hash| taxon_hash.fetch('details', {})['visible_to_departmental_editors'] }
    end

    def expand_taxon_array(taxons)
      taxons.map do |taxon_hash|
        taxon_hash.tap do |hash|
          hash['expanded_links_hash'] = tree_data(taxon_hash['content_id'])
        end
      end
    end

    def tree_data(content_id)
      get_expanded_links_hash(content_id, cache_expiry: 1.hour, with_drafts: true)
    end

    def all_taxon_data_including_draft
      @_all_data ||= get_root_taxons(with_drafts: true)
    end

    def get_root_taxons(with_drafts:)
      get_expanded_links_hash(HOMEPAGE_CONTENT_ID, cache_expiry: 24.hours, with_drafts: with_drafts)
        .fetch('expanded_links', {})
        .fetch('root_taxons', [])
    end

    def get_expanded_links_hash(content_id, cache_expiry:, with_drafts:)
      Rails.cache.fetch("#{self.class.name}_expanded_links_#{content_id}_#{with_drafts}", expires_in: cache_expiry) do
        Services.publishing_api.get_expanded_links(content_id, with_drafts: with_drafts).to_h
      end
    end
  end
end
