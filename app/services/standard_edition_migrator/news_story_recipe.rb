class StandardEditionMigrator::NewsStoryRecipe < StandardEditionMigrator::NewsArticleRecipe
  def configurable_document_type
    "news_story"
  end
end
