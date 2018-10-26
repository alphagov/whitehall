namespace :db do
  desc "Report any data integrity issues"
  task lint: :environment do
    require 'data_hygiene/orphaned_attachment_finder'
    o = DataHygiene::OrphanedAttachmentFinder.new
    warn o.summarize_by_type
  end
end
