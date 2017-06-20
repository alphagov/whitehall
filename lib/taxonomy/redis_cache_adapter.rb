module Taxonomy
  class RedisCacheAdapter
    DRAFT_TAXONS_CACHE_KEY = "govuk_taxonomy_draft_taxons".freeze
    PUBLISHED_TAXONS_CACHE_KEY = "govuk_taxonomy_published_taxons".freeze

    def initialize(redis_client: Redis.current, adapter: PublishingApiAdapter.new)
      @redis_client = redis_client
      @adapter = adapter
    end

    def draft_taxon_data
      JSON.parse redis_client.get(DRAFT_TAXONS_CACHE_KEY)
    end

    def published_taxon_data
      JSON.parse redis_client.get(PUBLISHED_TAXONS_CACHE_KEY)
    end

    def rebuild_caches
      set_draft_taxon_data
      set_published_taxon_data
    end

  private

    attr_reader :redis_client, :adapter

    def set_draft_taxon_data
      data = adapter.draft_taxon_data
      redis_client.set DRAFT_TAXONS_CACHE_KEY, JSON.dump(data)
    end

    def set_published_taxon_data
      data = adapter.published_taxon_data
      redis_client.set PUBLISHED_TAXONS_CACHE_KEY, JSON.dump(data)
    end
  end
end
