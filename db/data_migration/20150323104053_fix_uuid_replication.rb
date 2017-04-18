# Fix UUIDs that are incorrectly replicated

# Bare calls to `uuid` in MySQL aren't safe across replication, as the generated
# UUIDs will be different per server, see:
# http://dev.mysql.com/doc/refman/5.1/en/replication-rbr-safe-unsafe.html

# This migration works by capturing the UUID from the database in Ruby-land,
# then updating the database as a string value. This `UPDATE` statement will
# replicate to the slaves and fix the discrepancy, even though it won't change
# the actual data on the master machine, where it's run.

def fix_content_id(record)
  content_id = record.content_id
  record.update_columns(content_id: content_id)
  record
end

puts "Fixing Document..."
Document.find_each do |d|
  fix_content_id(d)
end

puts "Fixing Organisation..."
Organisation.find_each do |d|
  fix_content_id(d)
end

puts "Fixing Person..."
Person.find_each do |d|
  fix_content_id(d)
end

puts "Fixing Role..."
Role.find_each do |d|
  fix_content_id(d)
end

puts "Fixing WorldLocation..."
WorldLocation.find_each do |d|
  fix_content_id(d)
end

puts "Fixing WorldwideOrganisation..."
WorldwideOrganisation.find_each do |d|
  fix_content_id(d)
end

puts "Done"
