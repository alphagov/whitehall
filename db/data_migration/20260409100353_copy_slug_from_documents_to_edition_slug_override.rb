# Fetch all edition IDs for published and withdrawn editions first.
# This is a non-locking read that won't block Whitehall. If we try to do the whole update in one query
# the table gets locked because we can't use the state index when joining on the documents table.
# We do risk missing an edition that gets updated in between the select and the update but that risk seems acceptable.
find_slug_overrides_sql = <<-SQL
  SELECT e.id from editions e
  JOIN documents d ON e.document_id = d.id
  WHERE e.slug != d.slug
  AND e.state IN ('published','withdrawn')
SQL

edition_ids = ActiveRecord::Base.connection.select_values(find_slug_overrides_sql)

puts "Found #{edition_ids.size} editions requiring slug overrides"

update_sql = <<-SQL
  UPDATE editions e
  JOIN documents d ON e.document_id = d.id
  SET e.slug_override = d.slug
  WHERE e.id IN (#{edition_ids.join(',')})
SQL
updated_editions = ActiveRecord::Base.connection.update(update_sql)

puts "\nMigration complete. Slug overrides applied for #{updated_editions} editions."
