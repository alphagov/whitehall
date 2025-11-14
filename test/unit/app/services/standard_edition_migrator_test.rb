require "test_helper"

class StandardEditionMigratorTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  class TestRecipe
    def configurable_document_type
      "test_type"
    end

    def presenter
      # Picked at random
      PublishingApi::NewsArticlePresenter
    end

    def map_legacy_fields_to_block_content(_edition, translation)
      { "test_attribute" => "MODIFIED #{translation.body}" }
    end
  end

  describe "#initialize" do
    setup do
      ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type"))
      @recipe = "TestRecipe"
    end

    test "takes a scope and a recipe" do
      assert_nothing_raised do
        StandardEditionMigrator.new(scope: Edition.published, recipe: @recipe)
      end
    end

    test "raises exception if no scope provided" do
      assert_raises(ArgumentError) do
        StandardEditionMigrator.new(recipe: @recipe)
      end
    end

    test "raises exception if no recipe provided" do
      assert_raises(ArgumentError) do
        StandardEditionMigrator.new(scope: Edition.published)
      end
    end
  end

  describe "#preview" do
    setup do
      ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type"))
      @recipe = "TestRecipe"
    end

    test "summarises how many documents and editions will be migrated" do
      editor = create(:departmental_editor)
      speech = build(:speech)
      speech.save!
      speech.first_published_at = Time.zone.now
      speech.major_change_published_at = Time.zone.now
      force_publish(speech)
      speech.create_draft(editor)

      migrator = StandardEditionMigrator.new(scope: Speech.all, recipe: @recipe)
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

      migrator = StandardEditionMigrator.new(scope: NewsArticle.all, recipe: @recipe)
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

      migrator = StandardEditionMigrator.new(scope: NewsArticle.all, recipe: @recipe)
      summary = {
        unique_documents: 1,
        total_editions: 2,
      }

      assert_equal summary, migrator.preview
    end
  end
end
