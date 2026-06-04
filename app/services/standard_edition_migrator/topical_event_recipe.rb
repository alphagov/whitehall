class StandardEditionMigrator::TopicalEventRecipe
  def initialize(record)
    @legacy_topical_event = record
  end

  def build_edition(record)
    document = Document.new(document_type: "StandardEdition", content_id: record.content_id)
    attributes = {
      document:,
      configurable_document_type: configurable_document_type,
      state: "published",
      slug: record.slug,
      updated_at: record.updated_at.rfc3339,
    }
    attributes[:public_timestamp] = record.public_timestamp if record.respond_to?(:public_timestamp)
    edition = StandardEdition.new(attributes)

    translations.each do |translation|
      edition.translations.find_or_initialize_by(locale: translation.fixed_locale).update(
        title: title(translation),
        summary: summary(translation),
        block_content: map_legacy_fields_to_block_content(record, translation),
      )
    end

    edition
  end

  def translations
    [LocalisedModel.new(@legacy_topical_event, "en")]
  end

  def configurable_document_type
    "topical_event"
  end

  def presenter
    PublishingApi::TopicalEventPresenter
  end

  def title(legacy_topical_event)
    legacy_topical_event.name
  end

  def summary(legacy_topical_event)
    legacy_topical_event.summary
  end

  def map_legacy_fields_to_block_content(edition, _translation)
    raise WhitehallError, "Topical Events with About pages are not currently supported by the migrator" if edition.topical_event_about_page

    {
      "body" => edition.description,
    }
  end

  def ignore_legacy_content_fields(content)
    content[:details].delete(:end_date) # we're not carrying over duration fields to new topical events
    content
  end

  def ignore_new_content_fields(content)
    content.delete(:auth_bypass_ids) # these were not present on legacy topical events and are included by default on StandardEdition
    content
  end

  def ignore_legacy_links(links)
    links
  end

  def ignore_new_links(links)
    links
  end
end
