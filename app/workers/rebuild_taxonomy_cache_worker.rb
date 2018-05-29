class RebuildTaxonomyCacheWorker
  include Sidekiq::Worker

  def perform
    Taxonomy::RedisCacheAdapter.new.rebuild_caches
    Taxonomy::RedisCacheAdapter.new.rebuild_world_taxon_caches
  end
end
