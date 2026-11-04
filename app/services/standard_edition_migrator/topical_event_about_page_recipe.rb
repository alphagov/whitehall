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

  def ignore_new_content_fields(content)
    content.delete(:auth_bypass_ids) # these were not present on legacy topical event about pages and are included by default on StandardEdition

    content
  end

  def ignore_legacy_content_fields(content)
    if content[:details]
      content[:details].delete(:read_more) # read more link text will now be appended to Topical Event bodies themselves
    end

    # convert public_timestamp to a string in the same format as the StandardEdition equivalent
    content[:public_updated_at] = content[:public_updated_at].rfc3339 if content[:public_updated_at].respond_to?(:rfc3339)

    content
  end
end
