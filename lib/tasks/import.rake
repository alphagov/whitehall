require_relative "../../app/sidekiq/document_import_worker"

namespace :import do
  desc "Import a news article via its JSON representation (exported via content-publisher#3311)"
  task :news_article, %i[path_to_import_file] => :environment do |_, args|
    DocumentImportWorker.new.perform(args[:path_to_import_file])
  end

  desc "Import all news articles in a directory, asynchronously"
  task :news_articles_in_directory, %i[dir_path] => :environment do |_, args|
    Dir.glob("#{args[:dir_path]}/**/*.json").each do |file|
      DocumentImportWorker.perform_async(file)
    end
  end
end
