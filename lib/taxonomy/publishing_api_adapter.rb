module Taxonomy
  class PublishingApiAdapter
    HOMEPAGE_CONTENT_ID = "f3bbdec2-0e62-4520-a7fd-6ffd5d36e03a".freeze
    WORLD_CONTENT_ID = "91b8ef20-74e7-4552-880c-50e6d73c2ff9".freeze

    def taxon_data
      @_taxon_data = expand_taxon_array(
        level_one_taxons + [world_taxon]
      )
    end

  private

    def expand_taxon_array(taxons)
      taxons.map do |taxon_hash|
        taxon_hash.tap do |hash|
          hash['expanded_links_hash'] = expanded_links_hash(taxon_hash['content_id'])
        end
      end
    end

    def level_one_taxons
      expanded_links_hash(HOMEPAGE_CONTENT_ID).dig('expanded_links', 'level_one_taxons') || []
    end

    def world_taxon
      publishing_api_with_huge_timeout.get_content(WORLD_CONTENT_ID).to_h
    end

    def expanded_links_hash(content_id)
      publishing_api_with_huge_timeout.get_expanded_links(content_id, with_drafts: false).to_h
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
