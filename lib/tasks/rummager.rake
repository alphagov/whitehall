namespace :rummager do
  desc "Reindex published documents"
  task :index => :environment do
    Rummageable.index(Document.search_index_published)
    Rummageable.commit
  end
end
