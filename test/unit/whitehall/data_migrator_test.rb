require 'test_helper'

class MyData
  def self.migrate!
  end
end

module Whitehall
  class DataMigratorTest < ActiveSupport::TestCase

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

    test "#due returns all migrations except those which have already been run" do
      assert_equal ['20100101120000_migrate_some_data.rb'], @migrator.due.map(&:filename)
      DataMigrationRecord.create!(version: "20100101120000")
      assert_equal [], @migrator.due.map(&:filename)
    end

  end
end