require "test_helper"

class StandardEditionMigratorJobTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  describe "sidekiq_options" do
    it "runs in the standard_edition_migration queue and set to never retry" do
      assert_equal({ "retry" => 0, "queue" => "standard_edition_migration" }, StandardEditionMigratorJob.sidekiq_options)
    end
  end

  describe "#perform" do
    let(:recipe_class) { StandardEditionMigrator::BaseRecipe }
    let(:args) do
      {
        "model_class" => "Organisation",
        "recipe_class" => "StandardEditionMigrator::BaseRecipe",
        "migration_method" => "create_new_document",
        "raise_if_payloads_differ" => true,
      }
    end

    it "calls the migration method on StandardEditionMigrator for each record, in order" do
      first_record = create(:organisation)
      second_record = create(:organisation)

      sequence = sequence("migration")
      StandardEditionMigrator.expects(:create_new_document).with(first_record, recipe_class, raise_if_payloads_differ: true).in_sequence(sequence)
      StandardEditionMigrator.expects(:create_new_document).with(second_record, recipe_class, raise_if_payloads_differ: true).in_sequence(sequence)

      StandardEditionMigratorJob.new.perform([first_record.id, second_record.id], args)
    end

    it "retries a record that hits a deadlock" do
      legacy_record = create(:organisation)

      StandardEditionMigrator.expects(:create_new_document)
        .with(legacy_record, recipe_class, raise_if_payloads_differ: true)
        .twice
        .raises(ActiveRecord::Deadlocked)
        .then.returns(nil)
      GovukError.expects(:notify).never

      StandardEditionMigratorJob.new.perform([legacy_record.id], args)
    end

    it "gives up on a record after repeated deadlocks, reports the error and continues with the remaining records" do
      deadlocked_record = create(:organisation)
      next_record = create(:organisation)

      StandardEditionMigrator.expects(:create_new_document)
        .with(deadlocked_record, recipe_class, raise_if_payloads_differ: true)
        .times(StandardEditionMigratorJob::MAX_DEADLOCK_ATTEMPTS)
        .raises(ActiveRecord::Deadlocked)
      StandardEditionMigrator.expects(:create_new_document).with(next_record, recipe_class, raise_if_payloads_differ: true)
      GovukError.expects(:notify).with(instance_of(ActiveRecord::Deadlocked), has_entry(:extra, has_entry(:record_id, deadlocked_record.id)))

      StandardEditionMigratorJob.new.perform([deadlocked_record.id, next_record.id], args)
    end

    it "does not retry non-deadlock errors, but reports them and continues with the remaining records" do
      failing_record = create(:organisation)
      next_record = create(:organisation)

      StandardEditionMigrator.expects(:create_new_document)
        .with(failing_record, recipe_class, raise_if_payloads_differ: true)
        .once
        .raises(RuntimeError, "The legacy and new edition payloads differ after normalisation.")
      StandardEditionMigrator.expects(:create_new_document).with(next_record, recipe_class, raise_if_payloads_differ: true)
      GovukError.expects(:notify).with(instance_of(RuntimeError), has_entry(:extra, has_entry(:record_id, failing_record.id)))

      StandardEditionMigratorJob.new.perform([failing_record.id, next_record.id], args)
    end
  end
end
