require "test_helper"

class StandardEditionMigratorJobTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  describe "sidekiq_options" do
    it "runs in the standard_edition_migration queue and set to never retry" do
      assert_equal({ "retry" => 0, "queue" => "standard_edition_migration" }, StandardEditionMigratorJob.sidekiq_options)
    end
  end

  describe "#perform" do
    it "finds the Document by ID" do
      ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type"))
      document = create(:document)
      StandardEditionMigrator.stubs(:recipe_for).returns(StandardEditionMigratorJobTest::TestRecipe.new)
      job = StandardEditionMigratorJob.new
      job.stubs(:migrate_editions!)
      assert_nothing_raised do
        job.perform(document.id, "republish" => true, "compare_payloads" => true, "model_class" => "Document")
      end
    end

    it "raises exception if Document is not found" do
      invalid_document_id = 0
      StandardEditionMigrator.stubs(:recipe_for).returns(StandardEditionMigratorJobTest::TestRecipe.new)

      job = StandardEditionMigratorJob.new

      assert_raises(ActiveRecord::RecordNotFound) do
        job.perform(invalid_document_id, "republish" => true, "compare_payloads" => true, "model_class" => "Document")
      end
    end

    describe "#migrate_editions!" do
      setup do
        ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type"))
        StandardEditionMigrator.stubs(:recipe_for).returns(StandardEditionMigratorJobTest::TestRecipe.new)

        # stub the presenters - we'll test those separately
        TestPresenter.any_instance.stubs(:content).returns({ some: "content" })
        PublishingApi::StandardEditionPresenter.any_instance.stubs(:content).returns({ some: "content" })
        TestPresenter.any_instance.stubs(:links).returns({ some: "links" })
        PublishingApi::StandardEditionPresenter.any_instance.stubs(:links).returns({ some: "links" })

        editor = create(:departmental_editor)
        # 1. create a legacy document... ([Edition: draft])
        # TODO: it would be good to genericise this test so we don't have to update it when the
        # document type in question gets deleted from Whitehall. But a few attempts at this were
        # unsuccessful, so I've picked a document type that is likely to exist for a while yet.
        organisation = create(:organisation, :with_alternative_format_contact_email)
        superseded_edition = build(:publication, alternative_format_provider: organisation, body: "This is my legacy document type body")
        superseded_edition.save!
        superseded_edition.first_published_at = Time.zone.now
        superseded_edition.major_change_published_at = Time.zone.now
        # 2. publish it and then create a new draft ([Edition: published, Edition: draft])
        force_publish(superseded_edition)
        published_edition = superseded_edition.create_draft(editor)
        published_edition.body = "This is my updated body"
        published_edition.change_note = "Superseding edition"
        published_edition.save!
        # 3. create a new draft which we'll then delete
        force_publish(published_edition)
        deleted_edition = published_edition.create_draft(editor)
        deleted_edition.body = "This is my body to be deleted"
        deleted_edition.change_note = "Deleting draft edition"
        deleted_edition.save!
        deleted_edition.delete!
        # 4. publish it and then create a new draft ([Edition: superseded, Edition: published, Edition: draft])
        draft_edition = published_edition.create_draft(editor)
        draft_edition.body = "This is my updated body for the draft"
        draft_edition.change_note = "Superseding edition"
        draft_edition.save!

        # Calling `.reload` won't work now we've changed the type - so we'll have to re-fetch by Edition ID
        @superseded_edition_id = superseded_edition.id
        @published_edition_id = published_edition.id
        @deleted_edition_id = deleted_edition.id
        @draft_edition_id = draft_edition.id
        @document_id = draft_edition.document.id
      end

      test "doesn't change the document history" do
        change_history = Document.find(@document_id).change_history.to_json

        Sidekiq::Testing.inline! { StandardEditionMigratorJob.new.perform(@document_id, "republish" => true, "compare_payloads" => true, "model_class" => "Document") }

        assert_equal change_history, Document.find(@document_id).change_history.to_json
      end

      test "migrates all editions in the scope to the configurable_document_type variant of StandardEdition" do
        Sidekiq::Testing.inline! { StandardEditionMigratorJob.new.perform(@document_id, "republish" => true, "compare_payloads" => true, "model_class" => "Document") }
        superseded_edition = Edition.find(@superseded_edition_id)
        published_edition = Edition.find(@published_edition_id)
        draft_edition = Edition.find(@draft_edition_id)
        deleted_edition = Edition.unscoped.find(@deleted_edition_id)

        # It's a bit of a smell that we're having to set the document type at
        # both the edition and document level - a symptom of denormalisation.
        # TODO: write up an issue to fix this up.
        assert_equal "StandardEdition", superseded_edition.document.document_type
        assert_equal "StandardEdition", superseded_edition.type
        assert_equal "StandardEdition", published_edition.type
        assert_equal "StandardEdition", draft_edition.type
        assert_equal "StandardEdition", deleted_edition.type
        assert_equal "test_type", superseded_edition.configurable_document_type
        assert_equal "test_type", published_edition.configurable_document_type
        assert_equal "test_type", draft_edition.configurable_document_type
        assert_equal "test_type", deleted_edition.configurable_document_type
      end

      test "migrates all editions in the scope and retains their original states" do
        Sidekiq::Testing.inline! { StandardEditionMigratorJob.new.perform(@document_id, "republish" => true, "compare_payloads" => true, "model_class" => "Document") }
        superseded_edition = Edition.find(@superseded_edition_id)
        published_edition = Edition.find(@published_edition_id)
        draft_edition = Edition.find(@draft_edition_id)
        deleted_edition = Edition.unscoped.find(@deleted_edition_id)

        assert_equal "superseded", superseded_edition.state
        assert_equal "published", published_edition.state
        assert_equal "draft", draft_edition.state
        assert_equal "deleted", deleted_edition.state
      end

      test "defers to `map_legacy_fields_to_block_content` to set the block_content= field" do
        Sidekiq::Testing.inline! { StandardEditionMigratorJob.new.perform(@document_id, "republish" => true, "compare_payloads" => true, "model_class" => "Document") }
        superseded_edition = Edition.find(@superseded_edition_id)
        published_edition = Edition.find(@published_edition_id)
        deleted_edition = Edition.unscoped.find(@deleted_edition_id)
        draft_edition = Edition.find(@draft_edition_id)
        superseded_block_content = { "field_attribute" => "MODIFIED This is my legacy document type body" }
        published_block_content = { "field_attribute" => "MODIFIED This is my updated body" }
        deleted_block_content = { "field_attribute" => "MODIFIED This is my body to be deleted" }
        draft_block_content = { "field_attribute" => "MODIFIED This is my updated body for the draft" }

        assert_equal superseded_block_content, superseded_edition.block_content.to_h
        assert_equal published_block_content, published_edition.block_content.to_h
        assert_equal deleted_block_content, deleted_edition.block_content.to_h
        assert_equal draft_block_content, draft_edition.block_content.to_h
      end

      test "clears the legacy body field" do
        Sidekiq::Testing.inline! { StandardEditionMigratorJob.new.perform(@document_id, "republish" => true, "compare_payloads" => true, "model_class" => "Document") }
        superseded_edition = Edition.find(@superseded_edition_id)
        published_edition = Edition.find(@published_edition_id)
        deleted_edition = Edition.unscoped.find(@deleted_edition_id)
        draft_edition = Edition.find(@draft_edition_id)

        assert_nil superseded_edition.body
        assert_nil published_edition.body
        assert_nil deleted_edition.body
        assert_nil draft_edition.body
      end

      test "associated images and attachments are retained after migration" do
        draft_edition = Edition.find(@draft_edition_id)
        image = build(:image)
        attachment = build(:file_attachment, attachable: draft_edition)
        draft_edition.images << image
        draft_edition.attachments = [attachment]
        draft_edition.save!

        Sidekiq::Testing.inline! { StandardEditionMigratorJob.new.perform(@document_id, "republish" => true, "compare_payloads" => true, "model_class" => "Document") }

        draft_edition = Edition.find(@draft_edition_id)
        assert_equal draft_edition.images, [image]
        assert_equal draft_edition.attachments, [attachment]
      end

      test "migrates all translations of each edition" do
        draft_edition = Edition.find(@draft_edition_id)
        with_locale(:fr) do
          draft_edition.title = "french-title"
          draft_edition.summary = "french-summary"
          draft_edition.body = "french-body"
        end
        draft_edition.save!

        Sidekiq::Testing.inline! { StandardEditionMigratorJob.new.perform(@document_id, "republish" => true, "compare_payloads" => true, "model_class" => "Document") }

        draft_edition = Edition.find(@draft_edition_id)
        with_locale(:fr) do
          assert_equal "french-title", draft_edition.title
          assert_equal "french-summary", draft_edition.summary
          assert_equal "MODIFIED french-body", draft_edition.block_content.to_h["field_attribute"]
        end
      end

      test "rolls back the transaction if it encounters an exception" do
        # We update the Document towards the end of the migration process, so this should
        # be a reasonable simulation of a failure part way through the migration.
        Document.any_instance.stubs(:update_column).raises(StandardError.new("Simulated failure"))
        assert_raises(StandardError) do
          Sidekiq::Testing.inline! { StandardEditionMigratorJob.new.perform(@document_id, "republish" => true, "compare_payloads" => true, "model_class" => "Document") }
        end
        superseded_edition = Edition.find(@superseded_edition_id)
        published_edition = Edition.find(@published_edition_id)
        deleted_edition = Edition.unscoped.find(@deleted_edition_id)
        draft_edition = Edition.find(@draft_edition_id)
        assert_equal "Publication", superseded_edition.type
        assert_equal "Publication", published_edition.type
        assert_equal "Publication", deleted_edition.type
        assert_equal "Publication", draft_edition.type
      end

      test "re-presents document to Publishing API (on bulk publishing queue) when `republish => true` is passed" do
        PublishingApiDocumentRepublishingJob.any_instance.expects(:perform).with(Edition.find(@draft_edition_id).document.id, true).once

        Sidekiq::Testing.inline! { StandardEditionMigratorJob.new.perform(@document_id, "republish" => true, "compare_payloads" => true, "model_class" => "Document") }
      end

      test "doesn't re-present document to Publishing API if `republish => true` isn't passed" do
        PublishingApiDocumentRepublishingJob.any_instance.expects(:perform).with(Edition.find(@draft_edition_id).document.id, true).never

        Sidekiq::Testing.inline! { StandardEditionMigratorJob.new.perform(@document_id, "republish" => false, "compare_payloads" => true, "model_class" => "Document") }
      end

      test "doesn't re-present document to Publishing API if exception encountered during migration" do
        PublishingApiDocumentRepublishingJob.any_instance.expects(:perform).with(Edition.find(@draft_edition_id).document.id, true).never

        Document.any_instance.stubs(:update_column).raises(StandardError.new("Simulated failure"))
        assert_raises(StandardError) do
          Sidekiq::Testing.inline! { StandardEditionMigratorJob.new.perform(@document_id, "republish" => true, "compare_payloads" => true, "model_class" => "Document") }
        end
      end

      test "Calls ensure_payloads_remain_identical when `compare_payloads => true`" do
        calls = []
        StandardEditionMigratorJob.any_instance.stubs(:migrate_edition!)
        StandardEditionMigratorJob.any_instance.stubs(:ensure_payloads_remain_identical).with do |edition, _recipe|
          calls << edition.id
          true
        end

        Sidekiq::Testing.inline! { StandardEditionMigratorJob.new.perform(@document_id, "republish" => true, "compare_payloads" => true, "model_class" => "Document") }
        assert_equal [@published_edition_id, @draft_edition_id], calls
      end

      test "doesn't call ensure_payloads_remain_identical when `compare_payloads => true` isn't passed" do
        StandardEditionMigratorJob.any_instance.stubs(:migrate_edition!)
        StandardEditionMigratorJob.any_instance.expects(:ensure_payloads_remain_identical).never

        Sidekiq::Testing.inline! { StandardEditionMigratorJob.new.perform(@document_id, "republish" => true, "compare_payloads" => false, "model_class" => "Document") }
      end
    end

    describe "ensure_payloads_remain_identical logic" do
      setup do
        ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type"))
        StandardEditionMigrator.stubs(:recipe_for).returns(StandardEditionMigratorJobTest::TestRecipe.new)
        document = create(:document)
        create(:standard_edition, document: document) #  we need an edition of any type to attach to the document
        @document_id = document.id
      end

      test "compares the presenter outputs on non-superseded and deleted editions, before and after migration, and passes if they're identical" do
        StandardEditionMigratorJobTest::TestPresenter.any_instance.stubs(:content).returns({ some: "content" })
        PublishingApi::StandardEditionPresenter.any_instance.stubs(:content).returns({ some: "content" })
        StandardEditionMigratorJobTest::TestPresenter.any_instance.stubs(:links).returns({ some: "links" })
        PublishingApi::StandardEditionPresenter.any_instance.stubs(:links).returns({ some: "links" })

        assert_nothing_raised do
          Sidekiq::Testing.inline! { StandardEditionMigratorJob.new.perform(@document_id, "republish" => true, "compare_payloads" => true, "model_class" => "Document") }
        end
      end

      test "does no presenter comparison on superseded or deleted editions" do
        editor = create(:departmental_editor)
        # 1. create a draft edition of something... ([Edition: draft])
        document = create(:document)
        superseded_edition = create(:standard_edition, document: document) #  we need an edition of any type to attach to the document
        superseded_edition.save!
        superseded_edition.first_published_at = Time.zone.now
        superseded_edition.major_change_published_at = Time.zone.now
        # 2. publish it
        force_publish(superseded_edition)
        # 3. create a new draft which we'll then delete
        deleted_edition = superseded_edition.create_draft(editor)
        deleted_edition.body = "Edition to be deleted"
        deleted_edition.change_note = "Edition to be deleted"
        deleted_edition.save!
        deleted_edition.delete!
        # 4. create a new draft which will cause the original edition to be superseded ([Edition: published, Edition: draft])
        published_edition = superseded_edition.create_draft(editor)
        published_edition.body = "This is my updated body"
        published_edition.change_note = "Superseding edition"
        published_edition.save!
        # 5. publish it and then create a new draft ([Edition: superseded, Edition: published, Edition: draft])
        force_publish(published_edition)
        draft_edition = published_edition.create_draft(editor)
        draft_edition.body = "This is my updated body for the draft"
        draft_edition.change_note = "Superseding edition"
        draft_edition.save!

        published_edition_id = published_edition.id
        draft_edition_id = draft_edition.id
        document_id = draft_edition.document.id

        calls = []
        StandardEditionMigratorJob.any_instance.stubs(:ensure_payloads_remain_identical).with do |edition|
          calls << edition.id
          true
        end
        Sidekiq::Testing.inline! { StandardEditionMigratorJob.new.perform(document_id, "republish" => true, "compare_payloads" => true, "model_class" => "Document") }
        assert_equal [published_edition_id, draft_edition_id], calls
      end

      test "payload comparison passes even if the ordering is different" do
        StandardEditionMigratorJobTest::TestPresenter.any_instance.stubs(:content).returns({ some: "content", other: "stuff" })
        PublishingApi::StandardEditionPresenter.any_instance.stubs(:content).returns({ other: "stuff", some: "content" })
        StandardEditionMigratorJobTest::TestPresenter.any_instance.stubs(:links).returns({ some: "links", nested: { foo: "bar", baz: "bax" } })
        PublishingApi::StandardEditionPresenter.any_instance.stubs(:links).returns({ some: "links", nested: { baz: "bax", foo: "bar" } })

        assert_nothing_raised do
          Sidekiq::Testing.inline! { StandardEditionMigratorJob.new.perform(@document_id, "republish" => true, "compare_payloads" => true, "model_class" => "Document") }
        end
      end

      test "raises exception if 'content' payload differs" do
        StandardEditionMigratorJobTest::TestPresenter.any_instance.stubs(:content).returns({ some: "content" })
        PublishingApi::StandardEditionPresenter.any_instance.stubs(:content).returns({ some: "something else" })
        StandardEditionMigratorJobTest::TestPresenter.any_instance.stubs(:links).returns({ some: "links" })
        PublishingApi::StandardEditionPresenter.any_instance.stubs(:links).returns({ some: "links" })

        error = assert_raises(RuntimeError) do
          Sidekiq::Testing.inline! { StandardEditionMigratorJob.new.perform(@document_id, "republish" => true, "compare_payloads" => true, "model_class" => "Document") }
        end
        assert_match(/Presenter content mismatch after migration for Edition ID/, error.message)
      end

      test "raises exception if 'links' payload differs" do
        StandardEditionMigratorJobTest::TestPresenter.any_instance.stubs(:content).returns({ some: "content" })
        PublishingApi::StandardEditionPresenter.any_instance.stubs(:content).returns({ some: "content" })
        StandardEditionMigratorJobTest::TestPresenter.any_instance.stubs(:links).returns({ some: "links" })
        PublishingApi::StandardEditionPresenter.any_instance.stubs(:links).returns({ some: "something else" })

        error = assert_raises(RuntimeError) do
          Sidekiq::Testing.inline! { StandardEditionMigratorJob.new.perform(@document_id, "republish" => true, "compare_payloads" => true, "model_class" => "Document") }
        end
        assert_match(/Presenter links mismatch after migration for Edition ID/, error.message)
      end

      test "uses ignore_legacy_content_fields and ignore_new_content_fields hooks to filter out expected differences" do
        StandardEditionMigrator.stubs(:recipe_for).returns(StandardEditionMigratorJobTest::TestRecipeForIgnoreContentFields.new)
        # stub content to be identical except for one legacy field, and one new field
        StandardEditionMigratorJobTest::TestRecipeForIgnoreContentFields.new.presenter.any_instance.stubs(:content).returns({ some: "content", ignore_legacy: "old_value" })
        PublishingApi::StandardEditionPresenter.any_instance.stubs(:content).returns({ some: "content", ignore_new: "new_value" })

        # stub links to be identical
        StandardEditionMigratorJobTest::TestRecipeForIgnoreContentFields.new.presenter.any_instance.stubs(:links).returns({ some: "links" })
        PublishingApi::StandardEditionPresenter.any_instance.stubs(:links).returns({ some: "links" })

        assert_nothing_raised do
          Sidekiq::Testing.inline! { StandardEditionMigratorJob.new.perform(@document_id, "republish" => true, "compare_payloads" => true, "model_class" => "Document") }
        end
      end

      test "uses ignore_legacy_links and ignore_new_links hooks to filter out expected differences" do
        StandardEditionMigrator.stubs(:recipe_for).returns(StandardEditionMigratorJobTest::TestRecipeForIgnoreLinksFields.new)

        # stub content to be identical
        StandardEditionMigratorJobTest::TestRecipeForIgnoreLinksFields.new.presenter.any_instance.stubs(:content).returns({ some: "content" })
        PublishingApi::StandardEditionPresenter.any_instance.stubs(:content).returns({ some: "content" })

        # stub links to be identical except for one legacy field, and one new field
        StandardEditionMigratorJobTest::TestRecipeForIgnoreLinksFields.new.presenter.any_instance.stubs(:links).returns({ some: "links", ignore_legacy: "old_value" })
        PublishingApi::StandardEditionPresenter.any_instance.stubs(:links).returns({ some: "links", ignore_new: "new_value" })

        assert_nothing_raised do
          Sidekiq::Testing.inline! { StandardEditionMigratorJob.new.perform(@document_id, "republish" => true, "compare_payloads" => true, "model_class" => "Document") }
        end
      end
    end
  end

  describe "#perform with non-editionable records" do
    setup do
      ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type"))
      StandardEditionMigrator.stubs(:recipe_for).returns(StandardEditionMigratorJobTest::TestNonEditionableRecipe.new)

      TestNonEditionablePresenter.any_instance.stubs(:content).returns({ some: "content" })
      PublishingApi::StandardEditionPresenter.any_instance.stubs(:content).returns({ some: "content" })
      TestNonEditionablePresenter.any_instance.stubs(:links).returns({ some: "links" })
      PublishingApi::StandardEditionPresenter.any_instance.stubs(:links).returns({ some: "links" })

      @test_record = StandardEditionMigratorJobTest::TestNonEditionableRecord.new(
        id: 1,
        name: "My Event",
        summary: "Event summary",
        description: "Event description",
        content_id: SecureRandom.uuid,
      )
      TestNonEditionableRecord.register(@test_record)
    end

    teardown do
      TestNonEditionableRecord.clear
    end

    test "creates a new Document and StandardEdition, mapping fields from the recipe" do
      assert_difference("Document.count", 1) do
        assert_difference("Edition.count", 1) do
          perform_non_editionable_migration
        end
      end

      new_document = Document.last
      assert_equal "StandardEdition", new_document.document_type
      assert_equal @test_record.content_id, new_document.content_id

      new_edition = Edition.last
      assert_equal "published", new_edition.state
      assert_equal TestNonEditionableRecipe.new.configurable_document_type, new_edition.configurable_document_type
      assert_equal "My Event", new_edition.title
      assert_equal "Event summary", new_edition.summary
      assert_equal({ "description" => "Event description" }, new_edition[:block_content])
    end

    test "carries over translations from the non-editionable record to the new edition" do
      bilingual_record = TestNonEditionableRecord.new(
        id: 2,
        name: "",
        summary: "",
        description: "",
        content_id: SecureRandom.uuid,
        translations: [
          TestNonEditionableRecord::Translation.new(locale: :en, name: "english name", summary: "english summary", description: "english description"),
          TestNonEditionableRecord::Translation.new(locale: :cy, name: "welsh name", summary: "welsh summary", description: "welsh description"),
        ],
      )
      TestNonEditionableRecord.register(bilingual_record)

      Sidekiq::Testing.inline! do
        StandardEditionMigratorJob.new.perform(
          bilingual_record.id,
          "republish" => false,
          "compare_payloads" => false,
          "model_class" => "StandardEditionMigratorJobTest::TestNonEditionableRecord",
        )
      end

      new_edition = Edition.last
      en_translation = new_edition.translations.find_by(locale: "en")
      assert_not_nil en_translation
      assert_equal "english name", en_translation.title
      assert_equal "english summary", en_translation.summary

      cy_translation = new_edition.translations.find_by(locale: "cy")
      assert_not_nil cy_translation
      assert_equal "welsh name", cy_translation.title
      assert_equal "welsh summary", cy_translation.summary
    end

    test "the original non-editionable record is not deleted" do
      perform_non_editionable_migration

      assert TestNonEditionableRecord.find(@test_record.id).present?,
             "Expected original TestNonEditionableRecord to still exist after migration"
    end

    test "re-presents document to Publishing API when republish => true" do
      PublishingApiDocumentRepublishingJob.any_instance.expects(:perform).once

      perform_non_editionable_migration(republish: true)
    end

    test "republishes the newly created document (not some other document) when republish => true" do
      republished_document_id = nil
      PublishingApiDocumentRepublishingJob.any_instance.expects(:perform).with do |document_id, _bulk|
        republished_document_id = document_id
        true
      end

      perform_non_editionable_migration(republish: true)

      assert_equal Document.last.id, republished_document_id
    end

    test "runs payload comparison when compare_payloads => true and raises if content differs" do
      TestNonEditionablePresenter.any_instance.stubs(:content).returns({ some: "legacy content" })
      PublishingApi::StandardEditionPresenter.any_instance.stubs(:content).returns({ some: "different content" })

      error = assert_raises(RuntimeError) do
        perform_non_editionable_migration(compare_payloads: true)
      end

      assert_match(/Presenter content mismatch after migration for StandardEditionMigratorJobTest::TestNonEditionableRecord ID/, error.message)
    end

    test "runs payload comparison when compare_payloads => true and raises if links differ" do
      TestNonEditionablePresenter.any_instance.stubs(:links).returns({ some: "legacy links" })
      PublishingApi::StandardEditionPresenter.any_instance.stubs(:links).returns({ some: "different links" })

      error = assert_raises(RuntimeError) do
        perform_non_editionable_migration(compare_payloads: true)
      end

      assert_match(/Presenter links mismatch after migration for StandardEditionMigratorJobTest::TestNonEditionableRecord ID/, error.message)
    end

  private

    def perform_non_editionable_migration(republish: false, compare_payloads: false)
      Sidekiq::Testing.inline! do
        StandardEditionMigratorJob.new.perform(
          @test_record.id,
          "republish" => republish,
          "compare_payloads" => compare_payloads,
          "model_class" => "StandardEditionMigratorJobTest::TestNonEditionableRecord",
        )
      end
    end
  end

  class TestPresenter
    def initialize(_edition); end
    def content; end
    def links; end
  end

  class TestNonEditionablePresenter
    def initialize(_record); end
    def content; end
    def links; end
  end

  class TestRecipe
    def configurable_document_type
      "test_type"
    end

    def presenter
      StandardEditionMigratorJobTest::TestPresenter
    end

    def map_legacy_fields_to_block_content(translation)
      { "field_attribute" => "MODIFIED #{translation.body}" }
    end

    def ignore_legacy_content_fields(content)
      content
    end

    def ignore_new_content_fields(content)
      content
    end

    def ignore_legacy_links(links)
      links
    end

    def ignore_new_links(links)
      links
    end
  end

  class TestRecipeForIgnoreContentFields < TestRecipe
    def ignore_legacy_content_fields(content)
      content.delete(:ignore_legacy)
      content
    end

    def ignore_new_content_fields(content)
      content.delete(:ignore_new)
      content
    end
  end

  class TestRecipeForIgnoreLinksFields < TestRecipe
    def ignore_legacy_links(links)
      links.delete(:ignore_legacy)
      links
    end

    def ignore_new_links(links)
      links.delete(:ignore_new)
      links
    end
  end

  class TestNonEditionableRecipe < TestRecipe
    def presenter
      StandardEditionMigratorJobTest::TestNonEditionablePresenter
    end

    def title(record_translation)
      record_translation.name
    end

    def summary(record_translation)
      record_translation.summary
    end

    def map_legacy_fields_to_block_content(_record, record_translation)
      { "description" => record_translation.description }
    end
  end

  class TestNonEditionableRecord
    Translation = Struct.new(:locale, :name, :summary, :description, keyword_init: true)

    attr_reader :id, :name, :summary, :description, :content_id

    def initialize(id:, name:, summary:, description:, content_id:, translations: nil)
      @id = id
      @name = name
      @summary = summary
      @description = description
      @content_id = content_id
      @translations = translations
    end

    def translations
      @translations || [Translation.new(locale: :en, name: @name, summary: @summary, description: @description)]
    end

    def self.find(id)
      all_instances.find { |r| r.id == id } || raise(ActiveRecord::RecordNotFound)
    end

    def self.register(record)
      all_instances << record
    end

    def self.clear
      @all_instances = []
    end

    def self.all_instances
      @all_instances ||= []
    end
  end
end
