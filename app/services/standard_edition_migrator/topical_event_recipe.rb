class StandardEditionMigrator::TopicalEventRecipe < StandardEditionMigrator::BaseRecipe
  def legacy_presenter
    PublishingApi::TopicalEventPresenter
  end
end
