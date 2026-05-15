class StandardEditionMigrator
  def initialize(scope:)
    @scope = scope
  end

  def preview
    if document_scope?
      total_editions = @scope.sum { |doc| Edition.unscoped.where(document: doc).count }
      { unique_documents: @scope.count, total_editions: total_editions }
    else
      { unique_records: @scope.count }
    end
  end

  def migrate!(republish: false, compare_payloads: true)
    @scope.each do |record|
      StandardEditionMigratorJob.perform_async(
        record.id,
        { "republish" => republish, "compare_payloads" => compare_payloads, "model_class" => model_class_name },
      )
    end
  end

  def self.recipe_for(model)
    if model.is_a?(Edition)
      raise "No migration recipe defined for Edition type #{model.type}"
    end

    raise "No migration recipe defined for #{model.class.name}"
  end

private

  def model_class_name
    @scope.model.name
  end

  def document_scope?
    model_class_name == "Document"
  end
end
