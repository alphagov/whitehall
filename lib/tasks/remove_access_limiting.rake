desc "Set access limited to false for selected edition "
task :remove_access_limiting, %i[edition_id] => :environment do |_, args|
  id = args[:edition_id]
  edition = Edition.where(id:).first

  raise "Cannot find edition of ID #{id}." unless edition

  edition.access_limited = false
  edition.save!

  puts "Access limited successfully set to false for edition of ID #{id}."
end
