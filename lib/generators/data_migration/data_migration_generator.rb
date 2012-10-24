class DataMigrationGenerator < Rails::Generators::NamedBase
  include Rails::Generators::Migration
  source_root File.expand_path('../templates', __FILE__)

  def self.next_migration_number(path)
    Time.zone.now.utc.strftime("%Y%m%d%H%M%S")
  end

  def create_migration
    migration_template "data_migration.rb", Rails.root.join("db/data_migration", file_name)
  end
end
