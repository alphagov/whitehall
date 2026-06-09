require "test_helper"

class StandardEditionMigratorTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  setup do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type"))
    @legacy_editionable_document = create(:detailed_guide, :with_document, title: "Detailed Guide", summary: "Old summary", body: "Old body").document
    @legacy_non_editionable_record = create(:organisation)
  end

  describe "#preview_migration" do
    setup do
      ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type"))
    end

    test "raises exception if an Edition is passed" do
      edition = build(:edition)
      assert_raises(RuntimeError, "An Edition was passed. You must pass the Document instead (so that we can migrate all of its Editions)") do
        StandardEditionMigrator.preview_migration(edition, CustomRecipe)
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
        {:title=>nil,
         :locale=>"en",
         :publishing_app=>"whitehall",
         :redirects=>[],
         :update_type=>"minor",
         :description=>nil,
         :details=>{},
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
        + :description=>nil,
        + :details=>{},
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
        + :title=>nil,
        + :update_type=>"minor"}

        ===LINKS
        -{:old_link=>"old link"}
        +{}
      OUTPUT


      # Test with a legacy record which is Editionable (i.e. Document) - should preview migration of the latest Edition
      summary = StandardEditionMigrator.preview_migration(@legacy_editionable_document, CustomRecipe)
      assert_equal expected_output, summary.chomp

      # Test with a legacy record which is not Editionable - should preview migration of the record itself
      summary = StandardEditionMigrator.preview_migration(@legacy_non_editionable_record, CustomRecipe)
      assert_equal expected_output, summary.chomp
    end

    test "doesn't create any StandardEdition or Document, and doesn't persist any changes to the legacy record" do
      assert_no_difference [StandardEdition.method(:count), Document.method(:count)] do
        StandardEditionMigrator.preview_migration(@legacy_editionable_document, CustomRecipe)
      end

      assert_equal "Detailed Guide", @legacy_editionable_document.reload.editions.last.title
    end
  end

  describe "#perform_migration" do
    test "performs the migration and saves the new edition" do
      old_id = @legacy_editionable_document.content_id
      old_body = @legacy_editionable_document.editions.last.body
      StandardEditionMigrator.perform_migration(@legacy_editionable_document, CustomRecipe)
      edition = StandardEdition.last
      assert edition.persisted?
      assert_equal "test_type", edition.configurable_document_type
      assert_equal old_id, edition.document.content_id
      assert_equal "Title", edition.translations.first.title
      assert_equal({ "field_attribute" => old_body }, edition.translations.first.block_content)
    end
  end

  class CustomRecipe
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
      # In the real recipe this wouldn't be dynamic - we'd know what object we're dealing with
      edition_attrs[:document] = legacy_record.document if legacy_record.respond_to?(:document)
      @edition = StandardEdition.new(edition_attrs)

      if legacy_record.respond_to?(:document)
        legacy_record.translations.each do |translation|
          # Still operating on the newly initialized Edition in memory - careful use of `find_or_initialize_by`
          @edition.translations.find_or_initialize_by(locale: translation.locale).update(
            title: title(translation),
            summary: summary(translation),
            block_content: {
              "field_attribute" => "#{translation.body}",
            },
          )
        end
      else
        # TODO: test
        @edition.translations.build(
          locale: "en",
          title: title(legacy_record),
          summary: summary(legacy_record),
          block_content: { "field_attribute" => legacy_record.body },
        )
      end

      @artefacts_to_save = [@edition.translations].flatten

      @edition
    end

    def save_artefacts!(validate:)
      # This is where the Recipe can handle saving any associated artefacts (e.g. Features, Organisations, etc.).
      @artefacts_to_save.each do |artefact|
        # Translations need to be associated with the edition before they can be saved
        if artefact.respond_to?(:edition_id=)
          artefact.edition_id = @edition.id
        end
        artefact.save!(validate: validate)
      end
    end

    def title(_legacy_record)
      "Title"
    end

    def summary(_legacy_record)
      "summary"
    end

    # The below methods aren't used in Edition creation - they're used only for payload normalisation for comparison purposes

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

# require "test_helper"

# class StandardEditionMigratorTest < ActiveSupport::TestCase
#   extend Minitest::Spec::DSL

#   describe "#initialize" do
#     setup do
#       ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type"))
#     end

#     test "takes a scope" do
#       assert_nothing_raised do
#         StandardEditionMigrator.new(scope: Document.all)
#       end
#     end

#     test "raises exception if no scope provided" do
#       assert_raises(ArgumentError) do
#         StandardEditionMigrator.new
#       end
#     end
#   end

#   describe "#migrate!" do
#     setup do
#       ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type"))
#     end

#     test "enqueues a migration job for each unique document in the scope" do
#       editor = create(:departmental_editor)
#       some_doc_1 = build(:standard_edition)
#       some_doc_1.save!
#       some_doc_1.first_published_at = Time.zone.now
#       some_doc_1.major_change_published_at = Time.zone.now
#       force_publish(some_doc_1)
#       some_doc_1.create_draft(editor)

#       some_doc_2 = build(:standard_edition)
#       some_doc_2.save!
#       some_doc_2.first_published_at = Time.zone.now
#       some_doc_2.major_change_published_at = Time.zone.now
#       force_publish(some_doc_2)

#       migrator = StandardEditionMigrator.new(scope: Document.all)

#       StandardEditionMigratorJob.expects(:perform_async).with(some_doc_1.document.id, { "compare_payloads" => true, "model_class" => "Document" }).once
#       StandardEditionMigratorJob.expects(:perform_async).with(some_doc_2.document.id, { "compare_payloads" => true, "model_class" => "Document" }).once

#       migrator.migrate!
#     end

#     test "allows compare_payloads options to be passed to the job" do
#       some_doc = create(:standard_edition)

#       migrator = StandardEditionMigrator.new(scope: Document.all)

#       StandardEditionMigratorJob.expects(:perform_async).with(some_doc.document.id, { "compare_payloads" => false, "model_class" => "Document" }).once
#       migrator.migrate!(compare_payloads: false)
#     end

#     test "enqueues a migration job for each non-editionable record, passing the model class" do
#       org1 = create(:organisation)
#       org2 = create(:organisation)

#       migrator = StandardEditionMigrator.new(scope: Organisation.where(id: [org1.id, org2.id]))

#       StandardEditionMigratorJob.expects(:perform_async)
#         .with(org1.id, { "compare_payloads" => true, "model_class" => "Organisation" }).once
#       StandardEditionMigratorJob.expects(:perform_async)
#         .with(org2.id, { "compare_payloads" => true, "model_class" => "Organisation" }).once

#       migrator.migrate!
#     end
#   end

#   describe ".recipe_for" do
#     test "raises an error if passed an Edition type which has no recipe" do
#       edition = build(:edition)
#       assert_raises(RuntimeError, "No migration recipe defined for Edition type Edition") do
#         StandardEditionMigrator.recipe_for(edition)
#       end
#     end

#     test "raises an error if passed a model class which has no recipe" do
#       model = build(:organisation)
#       assert_raises(RuntimeError, "No migration recipe defined for Organisation") do
#         StandardEditionMigrator.recipe_for(model)
#       end
#     end

#     # test "returns the correct recipe for <FILL ME IN>" do
#     #   legacy_document_type = build(:x)
#     #   recipe = StandardEditionMigrator.recipe_for(legacy_document_type)
#     #   assert_instance_of StandardEditionMigrator::YourLegacyDocumentTypeRecipe, recipe
#     # end

#     test "returns the correct recipe for legacy topical events" do
#       legacy_topical_event = build(:topical_event)
#       recipe = StandardEditionMigrator.recipe_for(legacy_topical_event)
#       assert_equal StandardEditionMigrator::TopicalEventRecipe, recipe
#     end
#   end

#   describe ".preview_migration" do
#     test "instantiates and calls StandardEditionMigratorJob's `preview_migration` method" do
#       legacy_record = build(:edition)
#       recipe = stub("Recipe")

#       StandardEditionMigratorJob.any_instance.expects(:preview_migration).with(legacy_record, recipe).once

#       StandardEditionMigrator.preview_migration(legacy_record, recipe)
#     end
#   end

#   describe ".compare_payloads" do
#     test "instantiates and calls StandardEditionMigratorJob's `compare_payloads` method" do
#       legacy_record = build(:edition)
#       recipe = stub("Recipe")
#       standard_edition = stub("StandardEdition")

#       StandardEditionMigratorJob.any_instance.expects(:compare_payloads).with(legacy_record, standard_edition, recipe).once

#       StandardEditionMigrator.compare_payloads(legacy_record, standard_edition, recipe)
#     end
#   end
# end
