require "test_helper"
require_relative "./standard_edition_migrator/fixtures/hardcoded_presenter"
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

      it "returns string summary of content and links payloads before-and-after of the record itself" do
        legacy_presenter = StandardEditionMigrator::RecipeForNonEditionableRecord.new.legacy_presenter.new(@legacy_non_editionable_record)
        new_presenter = PublishingApi::StandardEditionPresenter.new(
          StandardEditionMigrator::RecipeForNonEditionableRecord.new.build_edition(@legacy_non_editionable_record),
        )
        expected_output = <<~OUTPUT
          OLD PAYLOAD
          ===CONTENT
          #{JSON.pretty_generate(legacy_presenter.content)}
          ===LINKS
          #{JSON.pretty_generate(legacy_presenter.links)}

          NEW PAYLOAD
          ===CONTENT
          #{JSON.pretty_generate(new_presenter.content)}
          ===LINKS
          #{JSON.pretty_generate(new_presenter.links)}
        OUTPUT

        summary = StandardEditionMigrator.preview_migration(@legacy_non_editionable_record, StandardEditionMigrator::RecipeForNonEditionableRecord)
        assert summary.start_with?(expected_output), "Expected output to start with:\n#{expected_output}\n\nActual output:\n#{summary}"
      end

      it "makes a call to `diff_payloads` for content and links" do
        StandardEditionMigrator.any_instance.expects(:diff_content_payloads).with(
          has_entries(
            recipe: instance_of(StandardEditionMigrator::RecipeForNonEditionableRecord),
            old_content: anything,
            new_content: anything,
          ),
        )
        StandardEditionMigrator.any_instance.expects(:diff_links_payloads).with(
          has_entries(
            recipe: instance_of(StandardEditionMigrator::RecipeForNonEditionableRecord),
            old_links: anything,
            new_links: anything,
          ),
        )
        StandardEditionMigrator.preview_migration(@legacy_non_editionable_record, StandardEditionMigrator::RecipeForNonEditionableRecord)
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

      it "returns string summary of content and links payloads before-and-after of the latest edition" do
        legacy_presenter = StandardEditionMigrator::RecipeForLegacyEditionableDocument.new.legacy_presenter.new(@legacy_editionable_document)
        new_presenter = PublishingApi::StandardEditionPresenter.new(
          StandardEditionMigrator::RecipeForLegacyEditionableDocument.new.build_edition(@legacy_editionable_document.latest_edition),
        )
        expected_output = <<~OUTPUT
          OLD PAYLOAD
          ===CONTENT
          #{JSON.pretty_generate(legacy_presenter.content)}
          ===LINKS
          #{JSON.pretty_generate(legacy_presenter.links)}

          NEW PAYLOAD
          ===CONTENT
          #{JSON.pretty_generate(new_presenter.content)}
          ===LINKS
          #{JSON.pretty_generate(new_presenter.links)}
        OUTPUT

        summary = StandardEditionMigrator.preview_migration(@legacy_editionable_document, StandardEditionMigrator::RecipeForLegacyEditionableDocument)
        assert summary.start_with?(expected_output), "Expected output to start with:\n#{expected_output}\n\nActual output:\n#{summary}"
      end

      it "makes a call to `diff_payloads` for content and links" do
        StandardEditionMigrator.any_instance.expects(:diff_content_payloads).with(
          has_entries(
            recipe: instance_of(StandardEditionMigrator::RecipeForLegacyEditionableDocument),
            old_content: anything,
            new_content: anything,
          ),
        )
        StandardEditionMigrator.any_instance.expects(:diff_links_payloads).with(
          has_entries(
            recipe: instance_of(StandardEditionMigrator::RecipeForLegacyEditionableDocument),
            old_links: anything,
            new_links: anything,
          ),
        )
        StandardEditionMigrator.preview_migration(@legacy_editionable_document, StandardEditionMigrator::RecipeForLegacyEditionableDocument)
      end
    end
  end

  describe "#diff_content_payloads (using `ignore_legacy_content_fields` and `ignore_new_content_fields`)" do
    it "returns a diff of the two payloads, ignoring any fields specified in the recipe" do
      old_content = {
        field_we_are_persisting_and_changing: "value that changed",
        field_we_are_persisting_unchanged: "foo",
        field_we_dont_care_about: "some old value we don't care about",
      }
      new_content = {
        field_we_are_persisting_and_changing: "new value",
        field_we_are_persisting_unchanged: "foo",
        new_field_that_has_no_legacy_equivalent: "hello",
      }
      recipe = Class.new {
        def ignore_legacy_content_fields(content)
          content.delete(:field_we_dont_care_about)
          content
        end

        def ignore_new_content_fields(content)
          content.delete(:new_field_that_has_no_legacy_equivalent)
          content
        end
      }.new

      diff = StandardEditionMigrator.diff_content_payloads(
        recipe: recipe,
        old_content: old_content,
        new_content: new_content,
      )

      expected_diff = <<~DIFF
         {
        -  "field_we_are_persisting_and_changing": "value that changed",
        +  "field_we_are_persisting_and_changing": "new value",
           "field_we_are_persisting_unchanged": "foo"
         }
      DIFF

      assert_equal expected_diff, diff
    end
  end

  describe "#diff_links_payloads (using `ignore_legacy_links` and `ignore_new_links`)" do
    it "returns a diff of the two payloads, ignoring any fields specified in the recipe" do
      old_links = {
        link_we_are_persisting_and_changing: "value that changed",
        link_we_are_persisting_unchanged: "foo",
        link_we_dont_care_about: "some old value we don't care about",
      }
      new_links = {
        link_we_are_persisting_and_changing: "new value",
        link_we_are_persisting_unchanged: "foo",
        new_link_that_has_no_legacy_equivalent: "hello",
      }
      recipe = Class.new {
        def ignore_legacy_links(links)
          links.delete(:link_we_dont_care_about)
          links
        end

        def ignore_new_links(links)
          links.delete(:new_link_that_has_no_legacy_equivalent)
          links
        end
      }.new

      diff = StandardEditionMigrator.diff_links_payloads(
        recipe: recipe,
        old_links: old_links,
        new_links: new_links,
      )

      expected_diff = <<~DIFF
         {
        -  "link_we_are_persisting_and_changing": "value that changed",
        +  "link_we_are_persisting_and_changing": "new value",
           "link_we_are_persisting_unchanged": "foo"
         }
      DIFF

      assert_equal expected_diff, diff
    end
  end
end
