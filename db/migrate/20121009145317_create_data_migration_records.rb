class CreateDataMigrationRecords < ActiveRecord::Migration
  class DataMigrationRecord < ActiveRecord::Base; end

  def change
    create_table :data_migration_records do |t|
      t.string :version
    end
    add_index :data_migration_records, :version, unique: true
    DataMigrationRecord.create!(version: "20121008103408")
  end
end
