require "test_helper"

class StandardEditionMigratorTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  describe "#initialize" do
    setup do
      ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type"))
    end

    test "takes a scope" do
      assert_nothing_raised do
        StandardEditionMigrator.new(scope: Edition.published)
      end
    end

    test "raises exception if no scope provided" do
      assert_raises(ArgumentError) do
        StandardEditionMigrator.new
      end
    end
  end

  describe "#preview" do
    setup do
      ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type"))
    end

    test "summarises how many documents and editions will be migrated" do
      editor = create(:departmental_editor)
      speech = build(:speech)
      speech.save!
      speech.first_published_at = Time.zone.now
      speech.major_change_published_at = Time.zone.now
      force_publish(speech)
      speech.create_draft(editor)

      migrator = StandardEditionMigrator.new(scope: Speech.all)
      summary = {
        unique_documents: 1,
        total_editions: 2,
      }

      assert_equal summary, migrator.preview
    end

    test "includes superseded editions in the scope" do
      editor = create(:departmental_editor)
      news_article = build(:news_article)
      news_article.save!
      news_article.first_published_at = Time.zone.now
      news_article.major_change_published_at = Time.zone.now
      force_publish(news_article)
      draft = news_article.create_draft(editor)
      draft.change_note = "Superseding edition"
      draft.save!
      force_publish(draft)

      migrator = StandardEditionMigrator.new(scope: NewsArticle.all)
      summary = {
        unique_documents: 1,
        total_editions: 2,
      }

      assert_equal summary, migrator.preview
    end

    test "includes deleted editions in the scope" do
      editor = create(:departmental_editor)
      news_article = create(:published_news_article)
      draft = news_article.create_draft(editor)
      draft.change_note = "Superseding edition"
      draft.save!
      draft.delete!(editor)

      migrator = StandardEditionMigrator.new(scope: NewsArticle.all)
      summary = {
        unique_documents: 1,
        total_editions: 2,
      }

      assert_equal summary, migrator.preview
    end
  end

  describe ".recipe_for" do
    test "returns the correct recipe for legacy news article news stories" do
      edition = build(:news_article_news_story)
      recipe = StandardEditionMigrator.recipe_for(edition)
      assert_instance_of StandardEditionMigrator::NewsStoryRecipe, recipe
    end

    test "returns the correct recipe for legacy news article press releases" do
      edition = build(:news_article_press_release)
      recipe = StandardEditionMigrator.recipe_for(edition)
      assert_instance_of StandardEditionMigrator::PressReleaseRecipe, recipe
    end

    test "returns the correct recipe for legacy news article government responses" do
      edition = build(:news_article_government_response)
      recipe = StandardEditionMigrator.recipe_for(edition)
      assert_instance_of StandardEditionMigrator::GovernmentResponseRecipe, recipe
    end

    test "returns the correct recipe for legacy news article world news stories" do
      edition = build(:news_article_world_news_story)
      recipe = StandardEditionMigrator.recipe_for(edition)
      assert_instance_of StandardEditionMigrator::WorldNewsStoryRecipe, recipe
    end
  end
end
