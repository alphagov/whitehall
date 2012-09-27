namespace :rummager do
  desc "Reindex published documents"
  task :index => ['rummager:index:specialist', 'rummager:index:government']

  namespace :index do
    task :government => :environment do
      Rummageable.index(Whitehall.government_search_index, Whitehall.government_search_index_name)
      Rummageable.commit(Whitehall.government_search_index_name)
    end

    task :specialist => :environment do
      Rummageable.index(Whitehall.detailed_guidance_search_index, Whitehall.detailed_guidance_search_index_name)
      Rummageable.commit(Whitehall.detailed_guidance_search_index_name)
    end
  end
end
