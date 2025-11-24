require "test_helper"

class StandardEditionMigratorWorkerTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  describe "sidekiq_options" do
    it "runs in the standard_edition_migration queue and set to never retry" do
      assert_equal({ "retry" => 0, "queue" => "standard_edition_migration" }, StandardEditionMigratorWorker.sidekiq_options)
    end
  end

  describe "#perform" do
    it "finds the Document by ID" do
      ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type"))
      document = create(:document)
      StandardEditionMigrator.stubs(:recipe_for).returns(StandardEditionMigratorWorkerTest::TestRecipe.new)
      worker = StandardEditionMigratorWorker.new
      worker.stubs(:migrate_editions!)
      assert_nothing_raised do
        worker.perform(document.id, "republish" => true, "compare_payloads" => true)
      end
    end

    it "raises exception if Document is not found" do
      invalid_document_id = 0
      StandardEditionMigrator.stubs(:recipe_for).returns(StandardEditionMigratorWorkerTest::TestRecipe.new)

      worker = StandardEditionMigratorWorker.new

      assert_raises(ActiveRecord::RecordNotFound) do
        worker.perform(invalid_document_id, "republish" => true, "compare_payloads" => true)
      end
    end

    describe "#migrate_editions!" do
      setup do
        ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type"))
        StandardEditionMigrator.stubs(:recipe_for).returns(StandardEditionMigratorWorkerTest::TestRecipe.new)

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
        # 3. publish it and then create a new draft ([Edition: superseded, Edition: published, Edition: draft])
        force_publish(published_edition)
        draft_edition = published_edition.create_draft(editor)
        draft_edition.body = "This is my updated body for the draft"
        draft_edition.change_note = "Superseding edition"
        draft_edition.save!

        # Calling `.reload` won't work now we've changed the type - so we'll have to re-fetch by Edition ID
        @superseded_edition_id = superseded_edition.id
        @published_edition_id = published_edition.id
        @draft_edition_id = draft_edition.id
        @document_id = draft_edition.document.id
      end

      test "migrates all editions in the scope to the configurable_document_type variant of StandardEdition" do
        Sidekiq::Testing.inline! { StandardEditionMigratorWorker.new.perform(@document_id, "republish" => true, "compare_payloads" => true) }
        superseded_edition = Edition.find(@superseded_edition_id)
        published_edition = Edition.find(@published_edition_id)
        draft_edition = Edition.find(@draft_edition_id)

        # It's a bit of a smell that we're having to set the document type at
        # both the edition and document level - a symptom of denormalisation.
        # TODO: write up an issue to fix this up.
        assert_equal "StandardEdition", superseded_edition.document.document_type
        assert_equal "StandardEdition", superseded_edition.type
        assert_equal "StandardEdition", published_edition.type
        assert_equal "StandardEdition", draft_edition.type
        assert_equal "test_type", superseded_edition.configurable_document_type
        assert_equal "test_type", published_edition.configurable_document_type
        assert_equal "test_type", draft_edition.configurable_document_type
      end

      test "migrates all editions in the scope and retains their original states" do
        Sidekiq::Testing.inline! { StandardEditionMigratorWorker.new.perform(@document_id, "republish" => true, "compare_payloads" => true) }
        superseded_edition = Edition.find(@superseded_edition_id)
        published_edition = Edition.find(@published_edition_id)
        draft_edition = Edition.find(@draft_edition_id)

        assert_equal "superseded", superseded_edition.state
        assert_equal "published", published_edition.state
        assert_equal "draft", draft_edition.state
      end

      test "defers to `map_legacy_fields_to_block_content` to set the block_content= field" do
        Sidekiq::Testing.inline! { StandardEditionMigratorWorker.new.perform(@document_id, "republish" => true, "compare_payloads" => true) }
        superseded_edition = Edition.find(@superseded_edition_id)
        published_edition = Edition.find(@published_edition_id)
        draft_edition = Edition.find(@draft_edition_id)

        superseded_block_content = { "test_attribute" => "MODIFIED This is my legacy document type body" }
        published_block_content = { "test_attribute" => "MODIFIED This is my updated body" }
        draft_block_content = { "test_attribute" => "MODIFIED This is my updated body for the draft" }

        assert_equal superseded_block_content, superseded_edition.block_content.to_h
        assert_equal published_block_content, published_edition.block_content.to_h
        assert_equal draft_block_content, draft_edition.block_content.to_h
      end

      test "clears the legacy body field" do
        Sidekiq::Testing.inline! { StandardEditionMigratorWorker.new.perform(@document_id, "republish" => true, "compare_payloads" => true) }
        superseded_edition = Edition.find(@superseded_edition_id)
        published_edition = Edition.find(@published_edition_id)
        draft_edition = Edition.find(@draft_edition_id)

        assert_nil superseded_edition.body
        assert_nil published_edition.body
        assert_nil draft_edition.body
      end

      test "associated images and attachments are retained after migration" do
        draft_edition = Edition.find(@draft_edition_id)
        image = build(:image)
        attachment = build(:file_attachment, attachable: draft_edition)
        draft_edition.images << image
        draft_edition.attachments = [attachment]
        draft_edition.save!

        Sidekiq::Testing.inline! { StandardEditionMigratorWorker.new.perform(@document_id, "republish" => true, "compare_payloads" => true) }

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

        Sidekiq::Testing.inline! { StandardEditionMigratorWorker.new.perform(@document_id, "republish" => true, "compare_payloads" => true) }

        draft_edition = Edition.find(@draft_edition_id)
        with_locale(:fr) do
          assert_equal "french-title", draft_edition.title
          assert_equal "french-summary", draft_edition.summary
          assert_equal "MODIFIED french-body", draft_edition.block_content.to_h["test_attribute"]
        end
      end

      test "rolls back the transaction if it encounters an exception" do
        # We update the Document towards the end of the migration process, so this should
        # be a reasonable simulation of a failure part way through the migration.
        Document.any_instance.stubs(:update_column).raises(StandardError.new("Simulated failure"))
        assert_raises(StandardError) do
          Sidekiq::Testing.inline! { StandardEditionMigratorWorker.new.perform(@document_id, "republish" => true, "compare_payloads" => true) }
        end
        superseded_edition = Edition.find(@superseded_edition_id)
        published_edition = Edition.find(@published_edition_id)
        draft_edition = Edition.find(@draft_edition_id)
        assert_equal "Publication", superseded_edition.type
        assert_equal "Publication", published_edition.type
        assert_equal "Publication", draft_edition.type
      end

      test "re-presents document to Publishing API (on bulk publishing queue) when `republish => true` is passed" do
        PublishingApiDocumentRepublishingWorker.any_instance.expects(:perform).with(Edition.find(@draft_edition_id).document.id, true).once

        Sidekiq::Testing.inline! { StandardEditionMigratorWorker.new.perform(@document_id, "republish" => true, "compare_payloads" => true) }
      end

      test "doesn't re-present document to Publishing API if `republish => true` isn't passed" do
        PublishingApiDocumentRepublishingWorker.any_instance.expects(:perform).with(Edition.find(@draft_edition_id).document.id, true).never

        Sidekiq::Testing.inline! { StandardEditionMigratorWorker.new.perform(@document_id, "republish" => false, "compare_payloads" => true) }
      end

      test "doesn't re-present document to Publishing API if exception encountered during migration" do
        PublishingApiDocumentRepublishingWorker.any_instance.expects(:perform).with(Edition.find(@draft_edition_id).document.id, true).never

        Document.any_instance.stubs(:update_column).raises(StandardError.new("Simulated failure"))
        assert_raises(StandardError) do
          Sidekiq::Testing.inline! { StandardEditionMigratorWorker.new.perform(@document_id, "republish" => true, "compare_payloads" => true) }
        end
      end

      test "Calls ensure_payloads_remain_identical when `compare_payloads => true`" do
        calls = []
        StandardEditionMigratorWorker.any_instance.stubs(:migrate_edition!)
        StandardEditionMigratorWorker.any_instance.stubs(:ensure_payloads_remain_identical).with do |edition, _recipe|
          calls << edition.id
          true
        end

        Sidekiq::Testing.inline! { StandardEditionMigratorWorker.new.perform(@document_id, "republish" => true, "compare_payloads" => true) }
        assert_equal [@published_edition_id, @draft_edition_id], calls
      end

      test "doesn't call ensure_payloads_remain_identical when `compare_payloads => true` isn't passed" do
        StandardEditionMigratorWorker.any_instance.stubs(:migrate_edition!)
        StandardEditionMigratorWorker.any_instance.expects(:ensure_payloads_remain_identical).never

        Sidekiq::Testing.inline! { StandardEditionMigratorWorker.new.perform(@document_id, "republish" => true, "compare_payloads" => false) }
      end
    end

    describe "ensure_payloads_remain_identical logic" do
      setup do
        ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type"))
        StandardEditionMigrator.stubs(:recipe_for).returns(StandardEditionMigratorWorkerTest::TestRecipe.new)
        document = create(:document)
        create(:standard_edition, document: document) #  we need an edition of any type to attach to the document
        @document_id = document.id
      end

      test "compares the presenter outputs on non-superseded editions, before and after migration, and passes if they're identical" do
        StandardEditionMigratorWorkerTest::TestPresenter.any_instance.stubs(:content).returns({ some: "content" })
        PublishingApi::StandardEditionPresenter.any_instance.stubs(:content).returns({ some: "content" })
        StandardEditionMigratorWorkerTest::TestPresenter.any_instance.stubs(:links).returns({ some: "links" })
        PublishingApi::StandardEditionPresenter.any_instance.stubs(:links).returns({ some: "links" })

        assert_nothing_raised do
          Sidekiq::Testing.inline! { StandardEditionMigratorWorker.new.perform(@document_id, "republish" => true, "compare_payloads" => true) }
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
        StandardEditionMigratorWorker.any_instance.stubs(:ensure_payloads_remain_identical).with do |edition|
          calls << edition.id
          true
        end
        Sidekiq::Testing.inline! { StandardEditionMigratorWorker.new.perform(document_id, "republish" => true, "compare_payloads" => true) }
        assert_equal [published_edition_id, draft_edition_id], calls
      end

      test "payload comparison passes even if the ordering is different" do
        StandardEditionMigratorWorkerTest::TestPresenter.any_instance.stubs(:content).returns({ some: "content", other: "stuff" })
        PublishingApi::StandardEditionPresenter.any_instance.stubs(:content).returns({ other: "stuff", some: "content" })
        StandardEditionMigratorWorkerTest::TestPresenter.any_instance.stubs(:links).returns({ some: "links", nested: { foo: "bar", baz: "bax" } })
        PublishingApi::StandardEditionPresenter.any_instance.stubs(:links).returns({ some: "links", nested: { baz: "bax", foo: "bar" } })

        assert_nothing_raised do
          Sidekiq::Testing.inline! { StandardEditionMigratorWorker.new.perform(@document_id, "republish" => true, "compare_payloads" => true) }
        end
      end

      test "raises exception if 'content' payload differs" do
        StandardEditionMigratorWorkerTest::TestPresenter.any_instance.stubs(:content).returns({ some: "content" })
        PublishingApi::StandardEditionPresenter.any_instance.stubs(:content).returns({ some: "something else" })
        StandardEditionMigratorWorkerTest::TestPresenter.any_instance.stubs(:links).returns({ some: "links" })
        PublishingApi::StandardEditionPresenter.any_instance.stubs(:links).returns({ some: "links" })

        error = assert_raises(RuntimeError) do
          Sidekiq::Testing.inline! { StandardEditionMigratorWorker.new.perform(@document_id, "republish" => true, "compare_payloads" => true) }
        end
        assert_match(/Presenter content mismatch after migration for Edition ID/, error.message)
      end

      test "raises exception if 'links' payload differs" do
        StandardEditionMigratorWorkerTest::TestPresenter.any_instance.stubs(:content).returns({ some: "content" })
        PublishingApi::StandardEditionPresenter.any_instance.stubs(:content).returns({ some: "content" })
        StandardEditionMigratorWorkerTest::TestPresenter.any_instance.stubs(:links).returns({ some: "links" })
        PublishingApi::StandardEditionPresenter.any_instance.stubs(:links).returns({ some: "something else" })

        error = assert_raises(RuntimeError) do
          Sidekiq::Testing.inline! { StandardEditionMigratorWorker.new.perform(@document_id, "republish" => true, "compare_payloads" => true) }
        end
        assert_match(/Presenter links mismatch after migration for Edition ID/, error.message)
      end

      test "uses ignore_legacy_content_fields and ignore_new_content_fields hooks to filter out expected differences" do
        StandardEditionMigrator.stubs(:recipe_for).returns(StandardEditionMigratorWorkerTest::TestRecipeForIgnoreContentFields.new)
        # stub content to be identical except for one legacy field, and one new field
        StandardEditionMigratorWorkerTest::TestRecipeForIgnoreContentFields.new.presenter.any_instance.stubs(:content).returns({ some: "content", ignore_legacy: "old_value" })
        PublishingApi::StandardEditionPresenter.any_instance.stubs(:content).returns({ some: "content", ignore_new: "new_value" })

        # stub links to be identical
        StandardEditionMigratorWorkerTest::TestRecipeForIgnoreContentFields.new.presenter.any_instance.stubs(:links).returns({ some: "links" })
        PublishingApi::StandardEditionPresenter.any_instance.stubs(:links).returns({ some: "links" })

        assert_nothing_raised do
          Sidekiq::Testing.inline! { StandardEditionMigratorWorker.new.perform(@document_id, "republish" => true, "compare_payloads" => true) }
        end
      end

      test "uses ignore_legacy_links and ignore_new_links hooks to filter out expected differences" do
        StandardEditionMigrator.stubs(:recipe_for).returns(StandardEditionMigratorWorkerTest::TestRecipeForIgnoreLinksFields.new)

        # stub content to be identical
        StandardEditionMigratorWorkerTest::TestRecipeForIgnoreLinksFields.new.presenter.any_instance.stubs(:content).returns({ some: "content" })
        PublishingApi::StandardEditionPresenter.any_instance.stubs(:content).returns({ some: "content" })

        # stub links to be identical except for one legacy field, and one new field
        StandardEditionMigratorWorkerTest::TestRecipeForIgnoreLinksFields.new.presenter.any_instance.stubs(:links).returns({ some: "links", ignore_legacy: "old_value" })
        PublishingApi::StandardEditionPresenter.any_instance.stubs(:links).returns({ some: "links", ignore_new: "new_value" })

        assert_nothing_raised do
          Sidekiq::Testing.inline! { StandardEditionMigratorWorker.new.perform(@document_id, "republish" => true, "compare_payloads" => true) }
        end
      end
    end
  end

  class TestPresenter
    def initialize(_edition); end
    def content; end
    def links; end
  end

  class TestRecipe
    def configurable_document_type
      "test_type"
    end

    def presenter
      StandardEditionMigratorWorkerTest::TestPresenter
    end

    def map_legacy_fields_to_block_content(_edition, translation)
      { "test_attribute" => "MODIFIED #{translation.body}" }
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
end
