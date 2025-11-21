class StandardEditionMigrator::PressReleaseRecipe < StandardEditionMigrator::NewsArticleRecipe
  def configurable_document_type
    "press_release"
  end
end
