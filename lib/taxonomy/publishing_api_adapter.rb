module Taxonomy
  class PublishingApiAdapter
    HOMEPAGE_CONTENT_ID = "f3bbdec2-0e62-4520-a7fd-6ffd5d36e03a".freeze
    WORLD_CONTENT_ID = "91b8ef20-74e7-4552-880c-50e6d73c2ff9".freeze

    def taxon_data
      @_taxon_data = expand_taxon_array(
        level_one_taxons,
      )
    end

    def world_taxon_data
      expanded_links_hash(WORLD_CONTENT_ID).dig("expanded_links", "child_taxons") || []
    end

  private

    def expand_taxon_array(taxons)
      taxons.map do |taxon_hash|
        taxon_hash.tap do |hash|
          hash["links"] = expanded_links_hash(
            taxon_hash["content_id"],
          )["expanded_links"]
        end
      end
    end

    def level_one_taxons
      expanded_links_hash(HOMEPAGE_CONTENT_ID).dig("expanded_links", "level_one_taxons") || []
    end

    def expanded_links_hash(content_id)
      Services.publishing_api_with_huge_timeout.get_expanded_links(content_id, with_drafts: false).to_h
    rescue GdsApi::HTTPNotFound
      {}
    end
  end
end
