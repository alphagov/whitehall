namespace :rummager do
  desc "Reindex published documents"
  task :index => ['rummager:index:specialist', 'rummager:index:government']

  namespace :index do
    task :government => :environment do
      Rummageable.index(Whitehall.government_search_index, "/government")
      Rummageable.commit("/government")
    end

    task :specialist => :environment do
      Rummageable.index(Whitehall.specialist_search_index, "/specialist")
      Rummageable.commit("/specialist")
    end
  end
end
