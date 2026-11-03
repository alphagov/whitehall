class StandardEditionMigrator::TopicalEventAboutPageRecipe < StandardEditionMigrator::BaseRecipe
  def legacy_presenter
    PublishingApi::TopicalEventAboutPagePresenter
  end

  def build_edition(record)
    attributes = {
      creator: User.find_by(name: "Scheduled Publishing Robot"),
      created_at: record.created_at,
      updated_at: record.updated_at,
      configurable_document_type: "topical_event_about_page",
      title: record.name,
      summary: record.summary,
      block_content: {
        "body" => record.body,
      },
      state: "published",
      # we can't know that the `updated_at` was a major change; all we can guarantee
      # is that the initial publication was a major change.
      major_change_published_at: record.created_at,
    }
    StandardEdition.new(attributes)
  end
end
