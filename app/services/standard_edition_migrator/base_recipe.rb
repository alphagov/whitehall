class StandardEditionMigrator::BaseRecipe
  def legacy_presenter
    raise NotImplementedError, "Subclasses must implement legacy_presenter!"
  end

  def build_edition(record)
    raise NotImplementedError, "Subclasses must implement build_edition!"
  end
end
