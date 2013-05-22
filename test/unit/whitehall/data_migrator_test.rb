require 'test_helper'

module Whitehall
  class DataMigratorTest < ActiveSupport::TestCase

    class MyData
      def self.migrate!
      end
    end

    setup do
      @logger = stub_everything("Logger")
      @migrator = DataMigrator.new(path: File.dirname(__FILE__) + "/../../fixtures/whitehall_data_migrator", logger: @logger)
    end

    test "finds all migrations in the specified directory" do
      assert_equal ['20100101120000_migrate_some_data.rb'], @migrator.migrations.map(&:filename)
      assert @migrator.migrations.first.is_a?(Whitehall::DataMigration)
    end

    test "#run runs all migrations" do
      MyData.expects(:migrate!)
      @migrator.run
    end

    test "#run runs each migration in a transaction" do
      DataMigrationRecord.stubs(:create!)
      ActiveRecord::Base.connection.expects(:transaction).yields
      MyData.expects(:migrate!)
      @migrator.run
    end

    test "#run records a data migration on success" do
      DataMigrationRecord.expects(:create!).with(version: "20100101120000")
      @migrator.run
    end

    test "#run runs data migrations in timestamp order" do
      earlier_migration = stub("earlier-migration", version: "20100101120000")
      later_migration = stub("later-migration", version: "20100101120001")
      chronological_order = sequence("chronological-order")
      @migrator.stubs(:due).returns([later_migration, earlier_migration])

      earlier_migration.expects(:run).in_sequence(chronological_order)
      later_migration.expects(:run).in_sequence(chronological_order)

      @migrator.run
    end

    test "#due returns all migrations except those which have already been run" do
      assert_equal ['20100101120000_migrate_some_data.rb'], @migrator.due.map(&:filename)
      DataMigrationRecord.create!(version: "20100101120000")
      assert_equal [], @migrator.due.map(&:filename)
    end

  end
end