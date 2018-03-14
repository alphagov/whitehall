module Taxonomy
  class RedisCacheAdapter
    TAXONS_CACHE_KEY = "govuk_taxonomy_taxons".freeze

    def initialize(redis_client: Redis.current, adapter: PublishingApiAdapter.new)
      @redis_client = redis_client
      @adapter = adapter
    end

    def taxon_data
      JSON.parse @redis_client.get(TAXONS_CACHE_KEY)
    end

    def rebuild_caches
      data = @adapter.taxon_data
      @redis_client.set TAXONS_CACHE_KEY, JSON.dump(data)
    end
  end
end
