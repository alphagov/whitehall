# Convert all tables to utf8mb4 in order to improve support for non-English languages.

connection = ActiveRecord::Base.connection
# Disable foreign key constraints because foreign keys using strings will prevent conversion due to a charset mismatch.
connection.execute "SET foreign_key_checks = 0;"
connection.tables.each do |table|
  puts "START: Converting table #{table} to utf8mb4"
  connection.execute "ALTER TABLE `#{table}` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
  puts "END: Converted table #{table} to utf8mb4"
end
connection.execute "SET foreign_key_checks = 1;"
