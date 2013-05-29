require 'test_helper'

module Whitehall
  class DataMigrationTest < ActiveSupport::TestCase
    self.use_transactional_fixtures = false

    class MyData
      def self.migrate!
      end
    end

    setup do
      migration_file_path = Rails.root.join('test/fixtures/whitehall_data_migrator/20100101120000_migrate_some_data.rb')
      @data_migration = DataMigration.new(migration_file_path, logger: stub_everything('logger'))
    end

    teardown do
      DataMigrationRecord.destroy_all
    end

    test "returns a humanised name" do
      assert_equal 'Migrate some data', @data_migration.name
    end

    test "returns the migration filename" do
      assert_equal '20100101120000_migrate_some_data.rb', @data_migration.filename
    end

    test "returns the migration version number" do
      assert_equal '20100101120000', @data_migration.version
    end

    test "#due? returns true if migration has not been run, false otherwise" do
      assert @data_migration.due?
      DataMigrationRecord.create!(version: @data_migration.version)
      refute @data_migration.due?
    end

    test '#run performs the migration and saves a record for it' do
      MyData.expects(:migrate!)
      @data_migration.run
      assert DataMigrationRecord.find_by_version(@data_migration.version)
    end

    test "#run will rollback any changes if the data migration fails part way through" do
      bad_migration_path = Rails.root.join('test/fixtures/whitehall_data_migrator/20130529103338_bad_data_migration_that_creates_a_person.rb')
      bad_migration = DataMigration.new(bad_migration_path, logger: stub_everything('logger'))

      assert_no_difference('Person.count') do
        bad_migration.run
      end
      refute DataMigrationRecord.find_by_version(bad_migration.version)
    end
  end
end
