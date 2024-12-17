class ConvertTextColumnsToUtf8mb4 < ActiveRecord::Migration[7.1]
  def up
    # Disable foreign key constraints because foreign keys using strings will prevent conversion
    execute "SET foreign_key_checks = 0;"
    ActiveRecord::Base.connection.tables.each do |table|
      next if table == "schema_migrations"

      execute "ALTER TABLE `#{table}` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
    end
    execute "SET foreign_key_checks = 1;"
  end
end
