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

  describe "#create_new_document" do
    it "performs the migration and saves a new document and edition, when given a legacy non-editionable record" do
      document = StandardEditionMigrator.create_new_document(@legacy_non_editionable_record, StandardEditionMigrator::RecipeForNonEditionableRecord)
      edition = StandardEdition.last

      assert_equal document.content_id, @legacy_non_editionable_record.content_id
      assert edition.persisted?
      assert_equal edition, document.editions.last
      assert_equal "test_type", edition.configurable_document_type
      assert_equal "Title", edition.translations.first.title
      assert_equal({ "field_attribute" => "Old body" }, edition.translations.first.block_content)
    end

    it "saves the edition, artefacts and document first without validation, then with validation" do
      capture_save_calls = lambda do |klass|
        calls = []
        original_save_bang = klass.instance_method(:save!)
        klass.define_method(:save!) do |*args, **kwargs, &block|
          calls << kwargs
          original_save_bang.bind(self).call(*args, **kwargs, &block)
        end

        [calls, -> { klass.define_method(:save!, original_save_bang) }]
      end

      standard_edition_calls, restore_standard_edition = capture_save_calls.call(StandardEdition)
      sitewide_setting_calls, restore_sitewide_setting = capture_save_calls.call(SitewideSetting)
      translation_calls, restore_translation = capture_save_calls.call(Edition::Translation)
      document_calls, restore_document = capture_save_calls.call(Document)

      document = StandardEditionMigrator.create_new_document(@legacy_non_editionable_record, StandardEditionMigrator::RecipeForNonEditionableRecord)
      edition = document.editions.last

      assert_includes standard_edition_calls, { validate: false }
      assert_includes standard_edition_calls, { validate: true }
      assert_includes sitewide_setting_calls, { validate: false }
      assert_includes sitewide_setting_calls, { validate: true }
      assert_includes translation_calls, { validate: false }
      assert_includes translation_calls, { validate: true }
      assert_includes document_calls, { validate: false }
      assert_includes document_calls, { validate: true }
      assert_equal edition.id, edition.translations.first.edition_id
    ensure
      restore_document.call
      restore_translation.call
      restore_sitewide_setting.call
      restore_standard_edition.call
    end

    it "rolls back the transaction if a validation issue is encountered" do
      Document.any_instance.stubs(:save!).returns(true)
      Document.any_instance.expects(:save!).with(validate: true).raises(WhitehallError.new("Validation failed: Title can't be blank"))

      assert_no_difference [StandardEdition.method(:count), Document.method(:count)] do
        error = assert_raises(WhitehallError) do
          StandardEditionMigrator.create_new_document(@legacy_non_editionable_record, StandardEditionMigrator::RecipeForNonEditionableRecord)
        end
        assert_equal "Validation failed: Title can't be blank", error.message
      end
    end

    it "raises exception if a Document is passed (we could handle this in theory, but for now, for simplicity we expect only non-Document records)" do
      document = build(:document)
      error = assert_raises(RuntimeError) do
        StandardEditionMigrator.create_new_document(document, StandardEditionMigrator::RecipeForNonEditionableRecord)
      end

      assert_equal "Cannot pass a Document to create_new_document", error.message
    end
  end

  describe "#migrate_existing_document" do
    it "migrates all of a given Document's Editions (including deleted and superseded ones)" do
      StandardEditionMigrator.migrate_existing_document(@legacy_editionable_document, StandardEditionMigrator::RecipeForLegacyEditionableDocument)

      assert_equal "StandardEdition", @legacy_editionable_document.document_type

      Edition.unscoped.where(document_id: @legacy_editionable_document.id).find_each do |edition|
        assert_equal "StandardEdition", edition.type
        assert_equal "test_type", edition.configurable_document_type
        assert_equal "Title", edition.translations.first.title
        assert_equal "Summary", edition.translations.first.summary
        assert_equal({ "field_attribute" => "Old body" }, edition.translations.first.block_content)
      end
    end

    it "saves the edition, artefacts and document first without validation, then with validation" do
      capture_save_calls = lambda do |klass|
        calls = []
        original_save_bang = klass.instance_method(:save!)
        klass.define_method(:save!) do |*args, **kwargs, &block|
          calls << kwargs
          original_save_bang.bind(self).call(*args, **kwargs, &block)
        end

        [calls, -> { klass.define_method(:save!, original_save_bang) }]
      end

      standard_edition_calls, restore_standard_edition = capture_save_calls.call(StandardEdition)
      sitewide_setting_calls, restore_sitewide_setting = capture_save_calls.call(SitewideSetting)
      translation_calls, restore_translation = capture_save_calls.call(Edition::Translation)

      document = StandardEditionMigrator.migrate_existing_document(@legacy_editionable_document, StandardEditionMigrator::RecipeForLegacyEditionableDocument)
      edition = document.editions.last

      assert_includes standard_edition_calls, { validate: false }
      assert_includes standard_edition_calls, { validate: true }
      assert_includes sitewide_setting_calls, { validate: false }
      assert_includes sitewide_setting_calls, { validate: true }
      assert_includes translation_calls, { validate: false }
      assert_includes translation_calls, { validate: true }
      assert_equal edition.id, edition.translations.first.edition_id
    ensure
      restore_translation.call
      restore_sitewide_setting.call
      restore_standard_edition.call
    end

    test "rolls back the transaction if a validation issue is encountered" do
      document = create(:document, document_type: "DetailedGuide")
      create(:draft_detailed_guide, document: document, title: "Detailed Guide", summary: "Summary", body: "Old body")
      Edition.any_instance.stubs(:save!).returns(true)
      Edition.any_instance.expects(:save!).with(validate: true).raises(WhitehallError.new("Validation failed: Title can't be blank"))

      error = assert_raises(WhitehallError) do
        StandardEditionMigrator.migrate_existing_document(@legacy_editionable_document, StandardEditionMigrator::RecipeForLegacyEditionableDocument)
      end
      assert_equal "Validation failed: Title can't be blank", error.message
      assert_equal "DetailedGuide", document.reload.document_type
      Edition.unscoped.where(document_id: document.id).find_each do |edition|
        assert_not_equal "StandardEdition", edition.type
      end
    end

    it "raises exception if a non-Document is passed (non-Documents should always use `create_new_document`)" do
      error = assert_raises(RuntimeError) do
        StandardEditionMigrator.migrate_existing_document(@legacy_non_editionable_record, StandardEditionMigrator::RecipeForLegacyEditionableDocument)
      end

      assert_equal "Cannot pass a non-Document to migrate_existing_document", error.message
    end
  end
end
