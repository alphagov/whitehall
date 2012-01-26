namespace :rummager do
  desc "Reindex published documents"
  task :index => :environment do
    Rummageable.index(Document.search_index_published + Organisation.search_index)
    Rummageable.commit
  end
end
