require "test_helper"

class GovernmentResponseRecipeTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  describe "#configurable_document_type" do
    test "returns the correct configurable document type" do
      recipe = StandardEditionMigrator::GovernmentResponseRecipe.new
      assert_equal "government_response", recipe.configurable_document_type
    end
  end

  describe "running it on StandardEditionMigrator" do
    test "migrates a Government Response edition correctly" do
      ConfigurableDocumentType.setup_test_types("government_response" => JSON.parse(File.read(Rails.root.join("app/models/configurable_document_types/government_response.json"))))
      recipe = StandardEditionMigrator::GovernmentResponseRecipe.to_s
      image = build(:image, caption: "This is a caption")
      edition = create(:news_article_government_response, body: "Sample body content", images: [image], lead_image: image)

      migrator = StandardEditionMigrator.new(
        scope: Edition.where(id: edition.id),
        recipe: recipe,
      )

      assert_nothing_raised do
        Sidekiq::Testing.inline! { migrator.migrate! }
      end

      migrated_edition = Edition.find(edition.id)
      assert_equal "StandardEdition", migrated_edition.type
      assert_equal "Sample body content", migrated_edition.block_content.body
      assert_equal edition.lead_image.image_data_id, migrated_edition.block_content.image
    end
  end
end
