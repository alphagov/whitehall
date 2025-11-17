class StandardEditionMigrator
  def initialize(scope:)
    @scope = scope
  end

  def preview
    total_editions = documents.sum { |doc| StandardEditionMigratorWorker.editions_for(doc).count }

    {
      unique_documents: documents.count,
      total_editions: total_editions,
    }
  end

  def migrate!(republish: true, compare_payloads: true)
    documents.each do |document|
      StandardEditionMigratorWorker.perform_async(document.id, { "republish" => republish, "compare_payloads" => compare_payloads })
    end
  end

  def self.recipe_for(edition)
    if edition.type == "NewsArticle"
      return case edition.news_article_type_id
             when 1
               StandardEditionMigrator::NewsStoryRecipe.new
             when 2
               StandardEditionMigrator::PressReleaseRecipe.new
             when 3
               StandardEditionMigrator::GovernmentResponseRecipe.new
             when 4
               StandardEditionMigrator::WorldNewsStoryRecipe.new
             else
               raise "No migration recipe defined for NewsArticle type " \
                     "#{edition.news_article_type_id.inspect} (Edition ID #{edition.id})"
             end
    end

    raise "No migration recipe defined for Edition type #{edition.type}"
  end

private

  def documents
    @documents ||= @scope.map(&:document).uniq
  end
end
