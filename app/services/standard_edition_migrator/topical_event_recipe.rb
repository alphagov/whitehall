class StandardEditionMigrator::TopicalEventRecipe
  def initialize(record)
    @legacy_topical_event = record
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
    content
  end

  def ignore_new_content_fields(content)
    content
  end

  def ignore_legacy_links(links)
    links
  end

  def ignore_new_links(links)
    links
  end
end
