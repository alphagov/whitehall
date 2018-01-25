module Taxonomy
  class PublishingApiAdapter
    HOMEPAGE_CONTENT_ID = "f3bbdec2-0e62-4520-a7fd-6ffd5d36e03a".freeze

    def draft_taxon_data
      @_draft_data ||= begin
        expand_taxon_array only_visible_taxons(draft_taxons_data)
      end
    end

    def published_taxon_data
      @_published_data ||= begin
        taxons = get_level_one_taxons(with_drafts: false)
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
      get_expanded_links_hash(content_id, with_drafts: true)
    end

    def all_taxon_data_including_draft
      @_all_data ||= get_level_one_taxons(with_drafts: true)
    end

    def draft_taxons_data
      published_taxon_content_ids = published_taxon_data.map do |taxon|
        taxon['content_id']
      end

      all_taxon_data_including_draft.reject do |taxon|
        published_taxon_content_ids.include? taxon['content_id']
      end
    end

    def get_level_one_taxons(with_drafts:)
      ids_from_publishing_api =
        get_expanded_links_hash(HOMEPAGE_CONTENT_ID, with_drafts: with_drafts)
          .fetch('expanded_links', {})
          .fetch('level_one_taxons', [])

      # The World taxons were removed from the Topic taxonomy, because
      # at least when the descision to remove them was made, they do
      # not meet the criteria for being suitable taxons.
      #
      # Unfortunately the tagging interface in Whitehall depends on
      # this link, so in the short term, add the World taxon in to
      # Whitehall as a level one taxon. This should be fixed somehow
      # in the future, but for now at least it's hard to tell what
      # will happen with the World taxons and the coresponding
      # navigation pages.
      (
        ids_from_publishing_api +
        [
          {
            'content_id' => '91b8ef20-74e7-4552-880c-50e6d73c2ff9'
          }
        ]
      ).uniq
    end

    def get_expanded_links_hash(content_id, with_drafts:)
      publishing_api_with_huge_timeout.get_expanded_links(content_id, with_drafts: with_drafts).to_h
    end

    def publishing_api_with_huge_timeout
      @publishing_api_with_huge_timeout ||= begin
        Services.publishing_api.dup.tap do |client|
          client.options[:timeout] = 60
        end
      end
    end
  end
end
