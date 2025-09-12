require_relative "../../app/sidekiq/document_import_worker"

namespace :import do
  desc "Import a news article via its JSON representation (exported via content-publisher#3311)"
  task :news_article, %i[path_to_import_file] => :environment do |_, args|
    DocumentImportWorker.new.perform(args[:path_to_import_file])
  end
end
