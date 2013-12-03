namespace :db do
  desc "Report any data integrity issues"
  task :lint => :environment do
    require 'data_hygiene/orphaned_attachment_finder'
    o = DataHygiene::OrphanedAttachmentFinder.new
    $stderr.puts o.summarize_by_type
  end
end

task :supporting_page_cleanup => :environment do
  require 'data_hygiene/supporting_page_cleaner'

  logger = Logger.new(Rails.root.join('log/supporting_page_cleanup.log'))

  Document.where(document_type: 'SupportingPage').find_each do |document|
    logger.info "Reparing: #{document.slug}"
    cleaner = SupportingPageCleaner.new(document, logger)
    cleaner.delete_duplicate_superseded_editions!
    cleaner.repair_version_history!
  end
end
