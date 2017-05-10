module Taxonomy
  class GovukTaxonomy
    HOMEPAGE_CONTENT_ID = "f3bbdec2-0e62-4520-a7fd-6ffd5d36e03a".freeze

    def children
      @_children ||= begin
        published_taxon_data
          .map { |taxon_hash| build_tree(taxon_hash) }
      end
    end

    def draft_child_taxons
      @_draft_child_taxons ||= begin
        draft_taxon_data
          .select { |taxon_hash| visible_to_departmental_editors?(taxon_hash) }
          .map { |taxon_hash| build_tree(taxon_hash) }
      end
    end

    def all_taxons
      @_all_taxons ||= children.flat_map(&:tree) + draft_child_taxons.flat_map(&:tree)
    end

  private

    def visible_to_departmental_editors?(taxon_hash)
      taxon_hash.fetch('details', {})['visible_to_departmental_editors']
    end

    def build_tree(taxon_hash)
      tree_data = get_expanded_links_hash(taxon_hash['content_id'], cache_expiry: 1.hour)
      taxon_hash['expanded_links_hash'] = tree_data
      Tree.new(taxon_hash).root_taxon
    end

    def draft_taxon_data
      @_draft_data ||= all_taxon_data_including_draft - published_taxon_data
    end

    def all_taxon_data_including_draft
      @_all_data ||= get_root_taxons(with_drafts: true)
    end

    def published_taxon_data
      @_published_data ||= get_root_taxons
    end

    def get_root_taxons(with_drafts: false)
      get_expanded_links_hash(HOMEPAGE_CONTENT_ID, with_drafts: with_drafts)
        .fetch('expanded_links', {})
        .fetch('root_taxons', [])
    end

    def get_expanded_links_hash(content_id, with_drafts: false, cache_expiry: 24.hours)
      Rails.cache.fetch("#{self.class.name}_expanded_links_#{content_id}_#{with_drafts}", expires_in: cache_expiry) do
        Services.publishing_api.get_expanded_links(content_id, with_drafts: with_drafts).to_h
      end
    end
  end
end
