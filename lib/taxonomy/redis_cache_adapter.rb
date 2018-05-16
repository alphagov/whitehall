module Taxonomy
  class RedisCacheAdapter
    TAXONS_CACHE_KEY = "topic_taxonomy_taxons".freeze
    WORLD_TAXONS_CACHE_KEY = "world_taxonomy_taxons".freeze

    def initialize(redis_client: Redis.current, adapter: PublishingApiAdapter.new)
      @redis_client = redis_client
      @adapter = adapter
    end

    def taxon_data
      JSON.parse @redis_client.get(TAXONS_CACHE_KEY)
    end

    def world_taxon_data
      JSON.parse @redis_client.get(WORLD_TAXONS_CACHE_KEY)
    end

    def rebuild_caches
      data = @adapter.taxon_data
      @redis_client.set TAXONS_CACHE_KEY, JSON.dump(data)
    end

    def rebuild_world_taxon_caches
      data = @adapter.world_taxon_data
      @redis_client.set WORLD_TAXONS_CACHE_KEY, JSON.dump(data)
    end
  end
end
