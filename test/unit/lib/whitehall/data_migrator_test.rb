require "test_helper"

module Whitehall
  class DataMigratorTest < ActiveSupport::TestCase
    setup do
      DataMigrationRecord.destroy_all
      @migrator = DataMigrator.new(path: "#{File.dirname(__FILE__)}/../../../fixtures/whitehall_data_migrator", logger: stub_everything("Logger"))
    end

    test "finds all migrations in the specified directory" do
      assert_equal ["20100101120000_migrate_some_data.rb", "20130529103338_bad_data_migration_that_creates_a_person.rb"], @migrator.migrations.map(&:filename)
      assert @migrator.migrations.first.is_a?(Whitehall::DataMigration)
    end

    test "#run runs data migrations in timestamp order" do
      earlier_migration = stub("earlier-migration", version: "20100101120000", due?: true)
      later_migration = stub("later-migration", version: "20100101120001", due?: true)
      @migrator.stubs(:migrations).returns(
        [
          earlier_migration,
          later_migration,
        ],
      )

      assert_equal([earlier_migration, later_migration], @migrator.due)
    end

    test "#due excludes migrations that have already been run" do
      assert_equal ["20100101120000_migrate_some_data.rb", "20130529103338_bad_data_migration_that_creates_a_person.rb"], @migrator.due.map(&:filename)
      DataMigrationRecord.create!(version: "20100101120000")
      assert_equal ["20130529103338_bad_data_migration_that_creates_a_person.rb"], @migrator.due.map(&:filename)
    end
  end
end
