namespace :rummager do
  desc "Reindex published documents"
  task :index => :environment do
    Rummageable.index(Whitehall.search_index)
    Rummageable.commit
  end
end
