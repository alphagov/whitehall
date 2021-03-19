require "rails/generators"

class DataMigrationGenerator < Rails::Generators::NamedBase
  def create_data_migration
    prefix = Time.zone.now.utc.strftime("%Y%m%d%H%M%S")
    create_file Rails.root.join("db/data_migration/#{prefix}_#{file_name}.rb")
  end
end
