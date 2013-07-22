require 'csv'

gds_user = User.find_by_name!("GDS Inside Government Team")
Edition::AuditTrail.whodunnit = gds_user

CSV.foreach('db/data_migration/20130718142536_fix_force_published_flag.csv') do |row|
  if document = Document.find_by_id(row.first)
    if edition = document.published_edition
      if (edition.force_published?) && edition.authors.include?(gds_user)
        # Call update_column because we don't want to cause another
        # visible update
        edition.update_column(:force_published, nil)
        puts "#{edition.title} un-force-published"
      end
    end
  end
end
