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
      slug_override: "about", #  slug is hardcoded, title is not
      block_content: {
        "body" => record.body,
      },
      state: "published",
      # we can't know that the `updated_at` was a major change; all we can guarantee
      # is that the initial publication was a major change.
      major_change_published_at: record.created_at,
    }
    edition = StandardEdition.new(attributes)
    edition.parent_edition_id = find_migrated_topical_event(record)
    edition
  end

  def after_save_edition(edition, _legacy_record)
    edition.parent_relationship.save!(validate: false)
  end

  def ignore_new_content_fields(content)
    content.delete(:auth_bypass_ids) # these were not present on legacy topical event about pages and are included by default on StandardEdition
    content.delete(:links) # legacy Topical Event About Pages had no edition links, but StandardEdition ones will

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

private

  def find_migrated_topical_event(record)
    edition = Edition.find_by(configurable_document_type: "topical_event", slug: record.topical_event.slug)
    raise WhitehallError, "You must migrate the Topical Event parent (#{record.topical_event.slug}) before migrating its About Page (ID: #{record.id})" unless edition

    edition.id
  end
end
