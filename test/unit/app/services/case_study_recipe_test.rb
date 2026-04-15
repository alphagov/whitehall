require "test_helper"

class CaseStudyRecipeTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  describe "running it on StandardEditionMigrator" do
    setup do
      ConfigurableDocumentType.setup_test_types("case_study" => JSON.parse(File.read(Rails.root.join("app/models/configurable_document_types/case_study.json"))))
    end

    test "migrates a Case Study edition correctly" do
      image_1 = build(:image, caption: "This is a caption", usage: "lead")
      image_2 = build(:image, caption: "This is a caption", usage: "lead")
      draft_edition = create(:draft_case_study, body: "Sample body content", images: [image_1])
      published_edition = create(:published_case_study, body: "Sample published body content", images: [image_2])

      migrator = StandardEditionMigrator.new(
        scope: Document.where(id: [draft_edition.document.id, published_edition.document.id]),
      )

      assert_nothing_raised do
        Sidekiq::Testing.inline! { migrator.migrate! }
      end

      migrated_draft = Edition.find(draft_edition.id)
      assert_equal "StandardEdition", migrated_draft.type
      assert_equal "Sample body content", migrated_draft.block_content.body
      assert_equal draft_edition.images, migrated_draft.images

      migrated_published = Edition.find(published_edition.id)
      assert_equal "StandardEdition", migrated_published.type
      assert_equal "Sample published body content", migrated_published.block_content.body
      assert_equal published_edition.images, migrated_published.images
    end

    test "migrates an unpublished Case Study edition correctly" do
      edition = create(:case_study, :unpublished, body: "Unpublished body content")

      migrator = StandardEditionMigrator.new(
        scope: Document.where(id: edition.document.id),
      )

      assert_nothing_raised do
        Sidekiq::Testing.inline! { migrator.migrate! }
      end

      migrated = Edition.unscoped.find(edition.id)
      assert_equal "StandardEdition", migrated.type
      assert_equal "Unpublished body content", migrated.block_content.body
    end

    test "migrates a Case Study edition with inline file attachments correctly" do
      edition = create(:published_case_study, body: "placeholder")
      attachment = build(:file_attachment, attachable: edition)
      edition.attachments << attachment
      edition.body = "Body with attachment\n\n[Attachment: #{attachment.filename}]"
      edition.save!(validate: false)

      migrator = StandardEditionMigrator.new(
        scope: Document.where(id: edition.document.id),
      )

      assert_nothing_raised do
        Sidekiq::Testing.inline! { migrator.migrate! }
      end

      migrated = Edition.find(edition.id)
      assert_equal "StandardEdition", migrated.type
      assert_equal edition.attachments, migrated.attachments
    end
  end
end
