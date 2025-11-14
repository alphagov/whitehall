require "test_helper"

class WorldNewsStoryRecipeTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  describe "#configurable_document_type" do
    test "returns the correct configurable document type" do
      recipe = StandardEditionMigrator::WorldNewsStoryRecipe.new
      assert_equal "world_news_story", recipe.configurable_document_type
    end
  end

  describe "#ignore_legacy_content_fields" do
    # World news stories have no 'organisations' - only 'worldwide organisations' -
    # and thus should have no 'emphasised_organisations' field. We always just sent
    # an empty array on legacy world news stories, but in the new StandardEdition
    # format we've decided it's cleaner to omit the field entirely.
    test "removes emphasised_organisations from content details" do
      recipe = StandardEditionMigrator::WorldNewsStoryRecipe.new
      content = {
        details: {
          emphasised_organisations: [],
          other_field: "value",
        },
      }
      updated_content = recipe.ignore_legacy_content_fields(content)
      assert_not_includes updated_content[:details].keys, :emphasised_organisations
      assert_equal "value", updated_content[:details][:other_field]
    end

    test "it calls `super` to inherit NewsArticleRecipe behavior" do
      # Monkey-patch to alias original method and raise a unique exception class we can assert.
      SuperCalled = Class.new(StandardError)
      StandardEditionMigrator::NewsArticleRecipe.class_eval do
        alias_method :__orig_ignore__, :ignore_legacy_content_fields
        define_method(:ignore_legacy_content_fields) { |_| raise SuperCalled, "super called" }
      end

      assert_raises(SuperCalled) do
        StandardEditionMigrator::WorldNewsStoryRecipe.new.ignore_legacy_content_fields(details: {})
      end
    ensure
      # Restore the original method so other tests are unaffected
      StandardEditionMigrator::NewsArticleRecipe.class_eval do
        alias_method :ignore_legacy_content_fields, :__orig_ignore__
        remove_method :__orig_ignore__
      end
    end
  end

  describe "running it on StandardEditionMigrator" do
    test "migrates a World News Story edition correctly" do
      ConfigurableDocumentType.setup_test_types("world_news_story" => JSON.parse(File.read(Rails.root.join("app/models/configurable_document_types/world_news_story.json"))))
      recipe = StandardEditionMigrator::WorldNewsStoryRecipe.to_s
      image = build(:image, caption: "This is a caption")
      edition = create(:news_article_world_news_story, body: "Sample body content", images: [image], lead_image: image)

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
