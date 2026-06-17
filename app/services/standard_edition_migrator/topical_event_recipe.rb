class StandardEditionMigrator::TopicalEventRecipe < StandardEditionMigrator::BaseRecipe
  def legacy_presenter
    PublishingApi::TopicalEventPresenter
  end

  def build_edition(record)
    raise WhitehallError, "Topical Events with About pages are not currently supported by the migrator" if record.topical_event_about_page

    StandardEdition.new(
      configurable_document_type: "topical_event",
      title: record.name,
      summary: record.summary,
      block_content: {
        "body" => record.description,
        "social_media_links" => record.social_media_accounts.map do |account|
          {
            "social_media_service_name" => account.service_name,
            "url" => account.url,
            "title" => account.display_name,
          }
        end,
      },
    )
  end
end
