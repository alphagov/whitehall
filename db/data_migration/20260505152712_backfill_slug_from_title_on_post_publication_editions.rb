update_sql = <<~SQL
  UPDATE editions
  SET slug_from_title = slug
  WHERE state IN ('published', 'withdrawn', 'unpublished')
    AND (
      (slug_override IS NULL OR slug_override = '')
      OR
      (slug_override IS NOT NULL AND slug_override != '' AND slug != slug_override)
    )
SQL
updated_editions = ActiveRecord::Base.connection.update(update_sql)

puts "Updated slug_from_title for #{updated_editions} editions"
