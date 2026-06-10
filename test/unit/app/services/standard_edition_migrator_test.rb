require "test_helper"

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
        StandardEditionMigrator.preview_migration(edition, RecipeForLegacyEditionableDocument)
      end
    end

    test "returns string summary of content and links payloads before-and-after, including a diff" do
      expected_output = <<~OUTPUT
        OLD PAYLOAD
        ===CONTENT
        {:body=>"OLD PAYLOAD", :some_old_field=>"some old value"}

        ===LINKS
        {:old_link=>"old link"}


        NEW PAYLOAD
        ===CONTENT
        {:title=>"Title",
         :locale=>"en",
         :publishing_app=>"whitehall",
         :redirects=>[],
         :update_type=>"minor",
         :description=>"summary",
         :details=>{:field_attribute=>"Old body"},
         :document_type=>"test_story",
         :public_updated_at=>"2011-11-11T11:11:11+00:00",
         :rendering_app=>"frontend",
         :schema_name=>"test_article",
         :links=>{},
         :auth_bypass_ids=>[nil],
         :base_path=>"/government/test/",
         :routes=>[{:path=>"/government/test/", :type=>"exact"}],
         :first_published_at=>2011-11-11 11:11:11.000000000 GMT +00:00}

        ===LINKS
        {}


        DIFF
        ===CONTENT
        -{:body=>"OLD PAYLOAD", :some_old_field=>"some old value"}
        +{:auth_bypass_ids=>[nil],
        + :base_path=>"/government/test/",
        + :description=>"summary",
        + :details=>{:field_attribute=>"Old body"},
        + :document_type=>"test_story",
        + :first_published_at=>2011-11-11 11:11:11.000000000 GMT +00:00,
        + :links=>{},
        + :locale=>"en",
        + :public_updated_at=>"2011-11-11T11:11:11+00:00",
        + :publishing_app=>"whitehall",
        + :redirects=>[],
        + :rendering_app=>"frontend",
        + :routes=>[{:path=>"/government/test/", :type=>"exact"}],
        + :schema_name=>"test_article",
        + :title=>"Title",
        + :update_type=>"minor"}

        ===LINKS
        -{:old_link=>"old link"}
        +{}
      OUTPUT

      # Test with a legacy record which is Editionable (i.e. Document) - should preview migration of the latest Edition
      summary = StandardEditionMigrator.preview_migration(@legacy_editionable_document, RecipeForLegacyEditionableDocument)
      assert_equal expected_output, summary.chomp

      # Test with a legacy record which is not Editionable - should preview migration of the record itself
      summary = StandardEditionMigrator.preview_migration(@legacy_non_editionable_record, RecipeForNonEditionableRecord)
      assert_equal expected_output, summary.chomp
    end

    test "raises an exception if the payloads diverge and `raise_if_payloads_differ` is true" do
      error = assert_raises(RuntimeError) do
        StandardEditionMigrator.preview_migration(@legacy_editionable_document, RecipeForLegacyEditionableDocument, raise_if_payloads_differ: true)
      end

      assert_equal "Payloads diverged between legacy and new presenters", error.message
    end

    test "doesn't create any StandardEdition or Document, and doesn't persist any changes to the legacy record" do
      assert_no_difference [StandardEdition.method(:count), Document.method(:count)] do
        StandardEditionMigrator.preview_migration(@legacy_editionable_document, RecipeForLegacyEditionableDocument)
      end

      assert_equal "Detailed Guide", @legacy_editionable_document.reload.editions.last.title
    end
  end

  describe "#create_new_document" do
    test "performs the migration and saves the new edition on a legacy non-editionable record" do
      StandardEditionMigrator.create_new_document(@legacy_non_editionable_record, RecipeForNonEditionableRecord)
      edition = StandardEdition.last
      assert edition.persisted?
      assert_equal "test_type", edition.configurable_document_type
      assert_equal "Title", edition.translations.first.title
      assert_equal({ "field_attribute" => "Old body" }, edition.translations.first.block_content)
    end

    test "raises exception if a Document is passed (we could handle this in theory, but for simplicity we expect all Document conversions to go through the migrate_existing_document route)" do
      document = build(:document)
      error = assert_raises(RuntimeError) do
        StandardEditionMigrator.create_new_document(document, RecipeForLegacyEditionableDocument)
      end

      assert_equal "Cannot pass a Document to create_new_document", error.message
    end
  end

  describe "#migrate_existing_document" do
    test "performs the migration and saves the new edition (and document) on a legacy editionable document" do
      old_id = @legacy_editionable_document.content_id
      old_body = @legacy_editionable_document.editions.last.body
      StandardEditionMigrator.migrate_existing_document(@legacy_editionable_document, RecipeForLegacyEditionableDocument)
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
        StandardEditionMigrator.migrate_existing_document(non_document, RecipeForLegacyEditionableDocument)
      end

      assert_equal "Cannot pass a non-Document to migrate_existing_document", error.message
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
        RecipeForNonEditionableRecord,
        migration_method: "create_new_document",
      )

      assert_equal 2, StandardEditionMigratorJob.jobs.size

      first_job_args = StandardEditionMigratorJob.jobs.first["args"]
      record_id = first_job_args.first
      keyword_args = first_job_args.second
      assert_equal legacy_non_editionable_records.first.id, record_id
      assert_equal "Organisation", keyword_args["model_class"]
      assert_equal "StandardEditionMigratorTest::RecipeForNonEditionableRecord", keyword_args["recipe_class"]
      assert_equal "create_new_document", keyword_args["migration_method"]

      second_job_args = StandardEditionMigratorJob.jobs.second["args"]
      record_id = second_job_args.first
      keyword_args = second_job_args.second
      assert_equal legacy_non_editionable_records.second.id, record_id
      assert_equal "Organisation", keyword_args["model_class"]
      assert_equal "StandardEditionMigratorTest::RecipeForNonEditionableRecord", keyword_args["recipe_class"]
      assert_equal "create_new_document", keyword_args["migration_method"]
    end
  end

  class RecipeForLegacyEditionableDocument < StandardEditionMigrator::BaseRecipe
    def legacy_presenter
      LegacyPresenter
    end

    def build_edition(legacy_record)
      edition_attrs = {
        configurable_document_type: "test_type",
        updated_at: legacy_record.updated_at.rfc3339,
        first_published_at: legacy_record.created_at.rfc3339,
        major_change_published_at: legacy_record.updated_at.rfc3339,
        creator: User.last,
        document: legacy_record.document,
      }
      @edition = StandardEdition.new(edition_attrs)

      legacy_record.translations.each do |translation|
        # Still operating on the newly initialized Edition in memory - careful use of `find_or_initialize_by`
        @edition.translations.find_or_initialize_by(locale: translation.locale).update(
          title: title(translation),
          summary: summary(translation),
          block_content: {
            "field_attribute" => translation.body.to_s,
          },
        )
      end

      @artefacts_to_save = @edition.translations
      @edition
    end

    def title(_legacy_record)
      "Title"
    end

    def summary(_legacy_record)
      "summary"
    end
  end

  class RecipeForNonEditionableRecord < StandardEditionMigrator::BaseRecipe
    def legacy_presenter
      LegacyPresenter
    end

    def build_edition(legacy_record)
      edition_attrs = {
        configurable_document_type: "test_type",
        updated_at: legacy_record.updated_at.rfc3339,
        first_published_at: legacy_record.created_at.rfc3339,
        major_change_published_at: legacy_record.updated_at.rfc3339,
        creator: User.last,
      }
      @edition = StandardEdition.new(edition_attrs)

      # NOTE: implementation will vary depending on non-editionable model.
      # Organisation has `translations` we can iterate over. TopicalEvent does not.
      legacy_record.translations.each do |translation|
        @edition.translations.find_or_initialize_by(locale: translation.locale).update(
          title: translation.name,
          summary: summary(legacy_record),
          block_content: {
            # Hardcoded for simplicity, so we can check the payload comes out the same
            # for both the editionable and non-editionable test cases.
            "field_attribute" => "Old body",
          },
        )
      end
      @artefacts_to_save = @edition.translations
      @edition
    end

    def title(_legacy_record)
      "Title"
    end

    def summary(_legacy_record)
      "summary"
    end
  end

  class LegacyPresenter
    def initialize(_legacy_record, update_type: nil, title: nil); end

    def content
      {
        "body": "OLD PAYLOAD",
        "some_old_field": "some old value",
      }
    end

    def links
      {
        "old_link": "old link",
      }
    end
  end
end
