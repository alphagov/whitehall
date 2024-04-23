desc "override email notifications from page level to taxon level, must be performed on a draft document collection that has never been published before."
task :set_email_override, %i[document_collection_id taxon_content_id dry_run] => :environment do |_, args|
  document_collection_id = args[:document_collection_id]
  taxon_content_id = args[:taxon_content_id]
  dry_run = args[:dry_run]

  email_overrider = EmailOveride::EmailOverride.new(document_collection_id:, taxon_content_id:, dry_run:)
  email_overrider.call
end
