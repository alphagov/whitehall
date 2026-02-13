class StandardEditionMigrator
  def initialize(scope:)
    @scope = scope
  end

  def preview
    total_editions = @scope.sum { |doc| Edition.unscoped.where(document: doc).count }

    {
      unique_documents: @scope.count,
      total_editions: total_editions,
    }
  end

  def migrate!(republish: false, compare_payloads: true)
    @scope.each do |document|
      StandardEditionMigratorWorker.perform_async(document.id, { "republish" => republish, "compare_payloads" => compare_payloads })
    end
  end

  def self.recipe_for(edition)
    raise "No migration recipe defined for Edition type #{edition.type}"
  end
end
