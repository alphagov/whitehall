namespace :rummager do
  desc "Reindex published documents"
  task :index => ['rummager:index:specialist', 'rummager:index:government']

  namespace :index do
    task :government => :environment do
      Rummageable.index(Whitehall.government_search_index, Whitehall.government_search_index_name)
      Rummageable.commit("/government")
    end

    task :specialist => :environment do
      Rummageable.index(Whitehall.detailed_guidance_search_index, Whitehall.detailed_guidance_search_index_name)
      Rummageable.commit("/specialist")
    end
  end
end
