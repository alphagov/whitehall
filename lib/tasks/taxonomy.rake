require 'redis-lock'

namespace :taxonomy do
  desc "Rebuild local redis cache of the taxonomy tree"
  task rebuild_cache: [:environment] do
    Redis.current.lock("rebuild_taxonomy_cache_worker_lock", life: 10.minutes, acquire: 1) do
      Rails.logger.info "Scheduling taxonomy cache rebuild"
      RebuildTaxonomyCacheWorker.perform_async
    end
  end
end
