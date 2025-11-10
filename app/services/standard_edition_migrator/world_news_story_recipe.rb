class StandardEditionMigrator::WorldNewsStoryRecipe < StandardEditionMigrator::NewsArticleRecipe
  def configurable_document_type
    "world_news_story"
  end

  def ignore_legacy_content_fields(content)
    content[:details].delete(:emphasised_organisations)
    super(content)
  end

  def ignore_legacy_links(links)
    links.delete(:organisations)
    links.delete(:original_primary_publishing_organisation)
    links.delete(:primary_publishing_organisation)
    links.delete(:people)
    links.delete(:roles)
    links
  end
end
