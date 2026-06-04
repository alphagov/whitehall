require "test_helper"

class StandardEditionMigratorTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  describe "#initialize" do
    setup do
      ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type"))
    end

    test "takes a scope" do
      assert_nothing_raised do
        StandardEditionMigrator.new(scope: Document.all)
      end
    end

    test "raises exception if no scope provided" do
      assert_raises(ArgumentError) do
        StandardEditionMigrator.new
      end
    end
  end

  describe "#preview" do
    setup do
      ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type"))
    end

    test "summarises how many documents and editions will be migrated" do
      editor = create(:departmental_editor)
      some_doc = build(:standard_edition)
      some_doc.save!
      some_doc.first_published_at = Time.zone.now
      some_doc.major_change_published_at = Time.zone.now
      force_publish(some_doc)
      some_doc.create_draft(editor)

      migrator = StandardEditionMigrator.new(scope: Document.where(id: some_doc.document.id))
      summary = {
        unique_documents: 1,
        total_editions: 2,
      }

      assert_equal summary, migrator.preview
    end

    test "includes superseded editions in the scope" do
      editor = create(:departmental_editor)
      some_doc = build(:standard_edition)
      some_doc.save!
      some_doc.first_published_at = Time.zone.now
      some_doc.major_change_published_at = Time.zone.now
      force_publish(some_doc)
      draft = some_doc.create_draft(editor)
      draft.change_note = "Superseding edition"
      draft.save!
      force_publish(draft)

      migrator = StandardEditionMigrator.new(scope: Document.where(id: some_doc.document.id))
      summary = {
        unique_documents: 1,
        total_editions: 2,
      }

      assert_equal summary, migrator.preview
    end

    test "includes deleted editions in the scope" do
      editor = create(:departmental_editor)
      some_doc = create(:published_standard_edition)
      draft = some_doc.create_draft(editor)
      draft.change_note = "Superseding edition"
      draft.save!
      draft.delete!(editor)

      migrator = StandardEditionMigrator.new(scope: Document.where(id: some_doc.document.id))
      summary = {
        unique_documents: 1,
        total_editions: 2,
      }

      assert_equal summary, migrator.preview
    end

    test "summarises how many non-editionable records will be migrated" do
      org1 = create(:organisation)
      org2 = create(:organisation)

      migrator = StandardEditionMigrator.new(scope: Organisation.where(id: [org1.id, org2.id]))

      assert_equal({ unique_records: 2 }, migrator.preview)
    end
  end

  describe "#migrate!" do
    setup do
      ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type"))
    end

    test "enqueues a migration job for each unique document in the scope" do
      editor = create(:departmental_editor)
      some_doc_1 = build(:standard_edition)
      some_doc_1.save!
      some_doc_1.first_published_at = Time.zone.now
      some_doc_1.major_change_published_at = Time.zone.now
      force_publish(some_doc_1)
      some_doc_1.create_draft(editor)

      some_doc_2 = build(:standard_edition)
      some_doc_2.save!
      some_doc_2.first_published_at = Time.zone.now
      some_doc_2.major_change_published_at = Time.zone.now
      force_publish(some_doc_2)

      migrator = StandardEditionMigrator.new(scope: Document.all)

      StandardEditionMigratorJob.expects(:perform_async).with(some_doc_1.document.id, { "compare_payloads" => true, "model_class" => "Document" }).once
      StandardEditionMigratorJob.expects(:perform_async).with(some_doc_2.document.id, { "compare_payloads" => true, "model_class" => "Document" }).once

      migrator.migrate!
    end

    test "allows compare_payloads options to be passed to the job" do
      some_doc = create(:standard_edition)

      migrator = StandardEditionMigrator.new(scope: Document.all)

      StandardEditionMigratorJob.expects(:perform_async).with(some_doc.document.id, { "compare_payloads" => false, "model_class" => "Document" }).once
      migrator.migrate!(compare_payloads: false)
    end

    test "enqueues a migration job for each non-editionable record, passing the model class" do
      org1 = create(:organisation)
      org2 = create(:organisation)

      migrator = StandardEditionMigrator.new(scope: Organisation.where(id: [org1.id, org2.id]))

      StandardEditionMigratorJob.expects(:perform_async)
        .with(org1.id, { "compare_payloads" => true, "model_class" => "Organisation" }).once
      StandardEditionMigratorJob.expects(:perform_async)
        .with(org2.id, { "compare_payloads" => true, "model_class" => "Organisation" }).once

      migrator.migrate!
    end
  end

  describe ".recipe_for" do
    test "raises an error if passed an Edition type which has no recipe" do
      edition = build(:edition)
      assert_raises(RuntimeError, "No migration recipe defined for Edition type Edition") do
        StandardEditionMigrator.recipe_for(edition)
      end
    end

    test "raises an error if passed a model class which has no recipe" do
      model = build(:organisation)
      assert_raises(RuntimeError, "No migration recipe defined for Organisation") do
        StandardEditionMigrator.recipe_for(model)
      end
    end

    # test "returns the correct recipe for <FILL ME IN>" do
    #   legacy_document_type = build(:x)
    #   recipe = StandardEditionMigrator.recipe_for(legacy_document_type)
    #   assert_instance_of StandardEditionMigrator::YourLegacyDocumentTypeRecipe, recipe
    # end
  end
end
