require "test_helper"

class CaseStudyRecipeTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  describe "running it on StandardEditionMigrator" do
    test "migrates a Case Study edition correctly" do
      ConfigurableDocumentType.setup_test_types("case_study" => JSON.parse(File.read(Rails.root.join("app/models/configurable_document_types/case_study.json"))))
      StandardEditionMigrator.stubs(:recipe_for).returns(StandardEditionMigrator::CaseStudyRecipe.new)
      image = build(:image, caption: "This is a caption", usage: "lead")
      edition = create(:published_case_study, body: "Sample body content", images: [image])

      migrator = StandardEditionMigrator.new(
        scope: Document.where(id: edition.document.id),
      )

      assert_nothing_raised do
        Sidekiq::Testing.inline! { migrator.migrate! }
      end

      migrated_edition = Edition.find(edition.id)
      assert_equal "StandardEdition", migrated_edition.type
      assert_equal "Sample body content", migrated_edition.block_content.body
      assert_equal edition.images, migrated_edition.images
    end
  end
end
