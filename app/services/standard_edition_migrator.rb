class StandardEditionMigrator
  def initialize(scope:)
    @scope = scope
  end

  def migrate!(compare_payloads: true)
    @scope.each do |record|
      StandardEditionMigratorJob.perform_async(
        record.id,
        { "compare_payloads" => compare_payloads, "model_class" => model_class_name },
      )
    end
  end

  def self.recipe_for(model)
    # if model.is_a?(<FILL ME IN>)
    #   return YourLegacyDocumentTypeRecipe.new
    # end

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
