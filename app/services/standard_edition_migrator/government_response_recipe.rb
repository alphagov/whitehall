class StandardEditionMigrator::GovernmentResponseRecipe < StandardEditionMigrator::NewsArticleRecipe
  def configurable_document_type
    "government_response"
  end
end
