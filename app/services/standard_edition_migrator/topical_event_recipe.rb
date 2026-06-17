class StandardEditionMigrator::TopicalEventRecipe < StandardEditionMigrator::BaseRecipe
  def legacy_presenter
    PublishingApi::TopicalEventPresenter
  end

  def build_edition(record)
    raise WhitehallError, "Topical Events with About pages are not currently supported by the migrator" if record.topical_event_about_page
  end
end
