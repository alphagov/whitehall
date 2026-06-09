update_sql = <<~SQL
  UPDATE editions
  SET access_limiting = 'organisations'
  WHERE access_limited = true
    AND access_limiting = 'none';
SQL
updated_editions = ActiveRecord::Base.connection.update(update_sql)

puts "Set access_limiting to 'organisations' for #{updated_editions} editions"
