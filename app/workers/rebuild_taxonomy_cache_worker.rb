require 'redis-lock'

class RebuildTaxonomyCacheWorker
  include Sidekiq::Worker

  def perform
    run_on_one_app_instance_only do
      Taxonomy::RedisCacheAdapter.new.rebuild_caches
    end
  end

private

  def run_on_one_app_instance_only
    Redis.current.lock(key, life: 600, acquire: 1) do
      yield
    end
  end

  def key
    "rebuild_taxonomy_cache_worker_lock"
  end
end
