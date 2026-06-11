require "test_helper"
require_relative "./standard_edition_migrator/fixtures/legacy_presenter"
require_relative "./standard_edition_migrator/fixtures/recipe_for_legacy_editionable_document"
require_relative "./standard_edition_migrator/fixtures/recipe_for_non_editionable_record"

class StandardEditionMigratorTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  setup do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type"))
    @legacy_editionable_document = create(:detailed_guide, :with_document, title: "Detailed Guide", summary: "Old summary", body: "Old body").document
    @legacy_non_editionable_record = create(:organisation, name: "Title")
  end

  describe "#preview_migration" do
    setup do
      ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type"))
    end

    test "raises exception if an Edition is passed" do
      edition = build(:edition)
      assert_raises(RuntimeError, "An Edition was passed. You must pass the Document instead (so that we can migrate all of its Editions)") do
        StandardEditionMigrator.preview_migration(edition, StandardEditionMigrator::RecipeForLegacyEditionableDocument)
      end
    end

    test "returns string summary of content and links payloads before-and-after, including a diff" do
      expected_output = <<~OUTPUT
        OLD PAYLOAD
        ===CONTENT
        {
          "body": "OLD PAYLOAD",
          "some_old_field": "some old value"
        }
        ===LINKS
        {
          "old_link": "old link"
        }

        NEW PAYLOAD
        ===CONTENT
        {
          "title": "Title",
          "locale": "en",
          "publishing_app": "whitehall",
          "redirects": [],
          "update_type": "minor",
          "description": "summary",
          "details": {
            "field_attribute": "Old body"
          },
          "document_type": "test_story",
          "public_updated_at": "2011-11-11T11:11:11+00:00",
          "rendering_app": "frontend",
          "schema_name": "test_article",
          "links": {},
          "auth_bypass_ids": [
            null
          ],
          "base_path": "/government/test/",
          "routes": [
            {
              "path": "/government/test/",
              "type": "exact"
            }
          ],
          "first_published_at": "2011-11-11 11:11:11 +0000"
        }
        ===LINKS
        {}

        DIFF
        ===CONTENT
         {
        -  "body": "OLD PAYLOAD",
        -  "some_old_field": "some old value"
        +  "auth_bypass_ids": [
        +    null
        +  ],
        +  "base_path": "/government/test/",
        +  "description": "summary",
        +  "details": {
        +    "field_attribute": "Old body"
        +  },
        +  "document_type": "test_story",
        +  "first_published_at": "2011-11-11 11:11:11 +0000",
        +  "links": {},
        +  "locale": "en",
        +  "public_updated_at": "2011-11-11T11:11:11+00:00",
        +  "publishing_app": "whitehall",
        +  "redirects": [],
        +  "rendering_app": "frontend",
        +  "routes": [
        +    {
        +      "path": "/government/test/",
        +      "type": "exact"
        +    }
        +  ],
        +  "schema_name": "test_article",
        +  "title": "Title",
        +  "update_type": "minor"
         }

        ===LINKS
        -{
        -  "old_link": "old link"
        -}
        +{}
      OUTPUT

      # Test with a legacy record which is Editionable (i.e. Document) - should preview migration of the latest Edition
      summary = StandardEditionMigrator.preview_migration(@legacy_editionable_document, StandardEditionMigrator::RecipeForLegacyEditionableDocument)
      assert_equal expected_output, summary.chomp

      # Test with a legacy record which is not Editionable - should preview migration of the record itself
      summary = StandardEditionMigrator.preview_migration(@legacy_non_editionable_record, StandardEditionMigrator::RecipeForNonEditionableRecord)
      assert_equal expected_output, summary.chomp
    end

    test "doesn't create any StandardEdition or Document, and doesn't persist any changes to the legacy record" do
      assert_no_difference [StandardEdition.method(:count), Document.method(:count)] do
        StandardEditionMigrator.preview_migration(@legacy_editionable_document, StandardEditionMigrator::RecipeForLegacyEditionableDocument)
      end

      assert_equal "Detailed Guide", @legacy_editionable_document.reload.editions.last.title
    end
  end

  describe "#create_new_document" do
    test "performs the migration and saves the new edition on a legacy non-editionable record" do
      StandardEditionMigrator.create_new_document(@legacy_non_editionable_record, StandardEditionMigrator::RecipeForNonEditionableRecord, raise_if_payloads_differ: false)
      edition = StandardEdition.last
      assert edition.persisted?
      assert_equal "test_type", edition.configurable_document_type
      assert_equal "Title", edition.translations.first.title
      assert_equal({ "field_attribute" => "Old body" }, edition.translations.first.block_content)
    end

    test "raises exception if a Document is passed (we could handle this in theory, but for simplicity we expect all Document conversions to go through the migrate_existing_document route)" do
      document = build(:document)
      error = assert_raises(RuntimeError) do
        StandardEditionMigrator.create_new_document(document, StandardEditionMigrator::RecipeForLegacyEditionableDocument, raise_if_payloads_differ: false)
      end

      assert_equal "Cannot pass a Document to create_new_document", error.message
    end

    test "raises an exception if the payloads diverge and `raise_if_payloads_differ` is true, and no changes are persisted" do
      error = nil
      assert_no_difference [StandardEdition.method(:count), Document.method(:count)] do
        error = assert_raises(RuntimeError) do
          StandardEditionMigrator.create_new_document(@legacy_non_editionable_record, StandardEditionMigrator::RecipeForNonEditionableRecord, raise_if_payloads_differ: true)
        end
      end

      assert_match(/^Payloads diverged between legacy and new presenters/, error.message)
    end
  end

  describe "#migrate_existing_document" do
    test "performs the migration and saves the new edition (and document) on a legacy editionable document" do
      old_id = @legacy_editionable_document.content_id
      old_body = @legacy_editionable_document.editions.last.body
      StandardEditionMigrator.migrate_existing_document(@legacy_editionable_document, StandardEditionMigrator::RecipeForLegacyEditionableDocument, raise_if_payloads_differ: false)
      edition = StandardEdition.last
      assert edition.persisted?
      assert_equal "test_type", edition.configurable_document_type
      assert_equal old_id, edition.document.content_id
      assert_equal "Title", edition.translations.first.title
      assert_equal({ "field_attribute" => old_body }, edition.translations.first.block_content)
    end

    test "raises exception if a non-Document is passed" do
      non_document = build(:organisation)
      error = assert_raises(RuntimeError) do
        StandardEditionMigrator.migrate_existing_document(non_document, StandardEditionMigrator::RecipeForLegacyEditionableDocument, raise_if_payloads_differ: false)
      end

      assert_equal "Cannot pass a non-Document to migrate_existing_document", error.message
    end

    test "raises an exception if the payloads diverge and `raise_if_payloads_differ` is true, and no changes are persisted" do
      error = nil
      assert_no_difference [StandardEdition.method(:count), Document.method(:count)] do
        error = assert_raises(RuntimeError) do
          StandardEditionMigrator.migrate_existing_document(@legacy_editionable_document, StandardEditionMigrator::RecipeForLegacyEditionableDocument, raise_if_payloads_differ: true)
        end
      end

      assert_match(/^Payloads diverged between legacy and new presenters/, error.message)
      assert_instance_of DetailedGuide, @legacy_editionable_document.reload.editions.last
    end
  end

  describe "#enqueue_bulk_migration" do
    test "enqueues a migration job for each legacy record, with the correct recipe and migration method" do
      legacy_non_editionable_records = [
        create(:organisation, name: "My first org"),
        create(:organisation, name: "My second org"),
      ]
      StandardEditionMigrator.enqueue_bulk_migration(
        legacy_non_editionable_records,
        StandardEditionMigrator::RecipeForNonEditionableRecord,
        migration_method: "create_new_document",
        raise_if_payloads_differ: true,
      )

      assert_equal 2, StandardEditionMigratorJob.jobs.size

      first_job_args = StandardEditionMigratorJob.jobs.first["args"]
      record_id = first_job_args.first
      keyword_args = first_job_args.second
      assert_equal legacy_non_editionable_records.first.id, record_id
      assert_equal "Organisation", keyword_args["model_class"]
      assert_equal "StandardEditionMigrator::RecipeForNonEditionableRecord", keyword_args["recipe_class"]
      assert_equal "create_new_document", keyword_args["migration_method"]
      assert_equal true, keyword_args["raise_if_payloads_differ"]

      second_job_args = StandardEditionMigratorJob.jobs.second["args"]
      record_id = second_job_args.first
      keyword_args = second_job_args.second
      assert_equal legacy_non_editionable_records.second.id, record_id
      assert_equal "Organisation", keyword_args["model_class"]
      assert_equal "StandardEditionMigrator::RecipeForNonEditionableRecord", keyword_args["recipe_class"]
      assert_equal "create_new_document", keyword_args["migration_method"]
      assert_equal true, keyword_args["raise_if_payloads_differ"]
    end
  end
end
