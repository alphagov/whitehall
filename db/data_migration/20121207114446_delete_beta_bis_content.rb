require 'csv'

data = CSV.read(__FILE__.gsub(/\.rb/, '.csv'), headers: true, encoding: "UTF-8")

creator = User.find_by_name!("Automatic Data Importer")

PaperTrail.whodunnit = creator

deleted = 0
not_deleted = 0

data.each do |row|
  edition_id = row['Admin URL'].split("/").last
  edition = Edition.unscoped.find(edition_id)
  next unless edition
  if edition.published?
    p "ERROR: Edition #{edition.id} is published"
    not_deleted += 1
  elsif ! edition.deleted?
    old_title = edition.title
    edition.title = "DELETED (#{old_title})"
    edition.delete
    puts "Deleted #{old_title}"
    deleted += 1
  end
end

puts "Deleted #{deleted} editions, #{not_deleted} failed"
