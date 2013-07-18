require 'csv'

gds_user = User.find_by_name!("GDS Inside Government Team")
Edition::AuditTrail.whodunnit = gds_user

CSV.foreach('db/data_migration/20130711131323_reindex_organisations_for_acronym_changes.csv') do |row|
  edition = Document.find(row.first).published_edition
  if edition && edition.force_published?
    if edition.authors.include? gds_user
      # Call update_column because we don't want to cause another
      # visible update
      edition.update_column(:force_published, nil)
      puts "#{edition.title} un-force-published"
    end
  end
end
