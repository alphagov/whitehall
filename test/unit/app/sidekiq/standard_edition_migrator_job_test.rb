require "test_helper"

class StandardEditionMigratorJobTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  describe "sidekiq_options" do
    it "runs in the standard_edition_migration queue and set to never retry" do
      assert_equal({ "retry" => 0, "queue" => "standard_edition_migration" }, StandardEditionMigratorJob.sidekiq_options)
    end
  end

  describe "#perform" do
    it "calls the migration method on StandardEditionMigrator with the correct arguments" do
      legacy_record = create(:organisation)
      recipe_class = StandardEditionMigrator::BaseRecipe

      StandardEditionMigrator.expects(:create_new_document).with(legacy_record, recipe_class, raise_if_payloads_differ: true)

      StandardEditionMigratorJob.new.perform(
        legacy_record.id,
        {
          "model_class" => "Organisation",
          "recipe_class" => "StandardEditionMigrator::BaseRecipe",
          "migration_method" => "create_new_document",
          "raise_if_payloads_differ" => true,
        },
      )
    end
  end
end
