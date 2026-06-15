require "test_helper"
require_relative "./standard_edition_migrator/fixtures/recipe_for_legacy_editionable_document"
require_relative "./standard_edition_migrator/fixtures/recipe_for_non_editionable_record"

class StandardEditionMigratorTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  setup do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type"))
    @legacy_non_editionable_record = create(:organisation, name: "Title")
    @legacy_editionable_document = create(:document, document_type: "DetailedGuide")
    create(:deleted_detailed_guide, document: @legacy_editionable_document, title: "Detailed Guide", summary: "Summary", body: "Old body")
    create(:superseded_detailed_guide, document: @legacy_editionable_document, title: "Detailed Guide", summary: "Summary", body: "Old body")
    create(:published_detailed_guide, document: @legacy_editionable_document, title: "Detailed Guide", summary: "Summary", body: "Old body")
    create(:draft_detailed_guide, document: @legacy_editionable_document, title: "Detailed Guide", summary: "Summary", body: "Old body")
  end

  describe "#preview_migration" do
    it "raises exception if an Edition is passed" do
      edition = build(:edition)
      assert_raises(RuntimeError, "An Edition was passed. You must pass the Document instead (so that we can migrate all of its Editions)") do
        StandardEditionMigrator.preview_migration(edition, StandardEditionMigrator::RecipeForLegacyEditionableDocument)
      end
    end

    context "when passing a non-editionable record" do
      let(:preview_migration) do
        StandardEditionMigrator.preview_migration(
          @legacy_non_editionable_record,
          StandardEditionMigrator::RecipeForNonEditionableRecord,
        )
      end

      it "doesn't create any StandardEdition or Document, and doesn't persist any changes to the legacy record" do
        before_attributes = @legacy_non_editionable_record.attributes

        assert_no_difference [StandardEdition.method(:count), Document.method(:count)] do
          preview_migration
        end

        assert_equal(
          before_attributes,
          @legacy_non_editionable_record.reload.attributes,
        )
      end

      it "passes the record to `compare_payloads`" do
        StandardEditionMigrator.any_instance.expects(:compare_payloads).with(
          @legacy_non_editionable_record,
          StandardEditionMigrator::RecipeForNonEditionableRecord,
        )
        StandardEditionMigrator.preview_migration(
          @legacy_non_editionable_record,
          StandardEditionMigrator::RecipeForNonEditionableRecord,
        )
      end
    end

    context "when passing an editionable record" do
      let(:preview_migration) do
        StandardEditionMigrator.preview_migration(@legacy_editionable_document, StandardEditionMigrator::RecipeForLegacyEditionableDocument)
      end

      it "doesn't create any StandardEdition or Document, and doesn't persist any changes to the legacy record" do
        before_attributes = @legacy_editionable_document.attributes
        before_attributes_on_edition = @legacy_editionable_document.editions.last.attributes

        assert_no_difference [StandardEdition.method(:count), Document.method(:count)] do
          preview_migration
        end

        assert_equal(
          before_attributes,
          @legacy_editionable_document.reload.attributes,
        )
        assert_equal(
          before_attributes_on_edition,
          @legacy_editionable_document.editions.last.reload.attributes,
        )
      end

      it "passes the latest edition to `compare_payloads`" do
        StandardEditionMigrator.any_instance.expects(:compare_payloads).with(
          @legacy_editionable_document.editions.last,
          StandardEditionMigrator::RecipeForLegacyEditionableDocument,
        )
        StandardEditionMigrator.preview_migration(
          @legacy_editionable_document,
          StandardEditionMigrator::RecipeForLegacyEditionableDocument,
        )
      end
    end
  end
end
