class StandardEditionMigrator
  def initialize(scope:, recipe:)
    @scope = scope
    @recipe = recipe
  end

  def preview
    total_editions = documents.sum { |doc| StandardEditionMigratorWorker.editions_for(doc).count }

    {
      unique_documents: documents.count,
      total_editions: total_editions,
    }
  end

  def migrate!
    documents.each do |document|
      StandardEditionMigratorWorker.perform_async(document.id, @recipe)
    end
  end

private

  def documents
    @documents ||= @scope.map(&:document).uniq
  end
end
