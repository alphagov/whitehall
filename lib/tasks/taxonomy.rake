require 'redis-lock'

namespace :taxonomy do
  task rebuild_cache: [:environment] do
    Redis.current.lock("rebuild_taxonomy_cache_worker_lock", life: 10.minutes, acquire: 1) do
      Rails.logger.info "Scheduling taxonomy cache rebuild"
      RebuildTaxonomyCacheWorker.perform_async
    end
  end
end
