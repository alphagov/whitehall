namespace :taxonomy do
  task rebuild_cache: [:environment] do
    RebuildTaxonomyCacheWorker.perform_async
  end
end
