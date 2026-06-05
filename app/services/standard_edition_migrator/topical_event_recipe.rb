class StandardEditionMigrator::TopicalEventRecipe
  def initialize(record)
    @legacy_topical_event = record
  end

  def build_edition(record)
    document = Document.new(document_type: "StandardEdition", content_id: record.content_id)
    feature_lists = [FeatureList.new(locale: "en")]
    features = []

    record.topical_event_featurings.each do |featuring|
      featured_image = FeaturedImageData.new(
        carrierwave_image: featuring.image.carrierwave_image,
      )
      featuring.image.assets.each do |asset|
        duplicated_asset = asset.dup
        duplicated_asset.assetable = featured_image
        featured_image.assets << duplicated_asset
      end

      features << Feature.new(
        document: featuring.edition&.document,
        offsite_link: featuring.offsite_link,
        image: featured_image,
        alt_text: featuring.alt_text,
        # ordering: featuring.ordering, # TODO: no ordering needed?
      )
    end
    feature_lists.first.features = features
    attributes = {
      document:,
      configurable_document_type: configurable_document_type,
      state: "published",
      slug: record.slug,
      updated_at: record.updated_at.rfc3339,
      feature_lists: feature_lists,
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
      "social_media_links" => edition.social_media_accounts.map do |account|
        {
          "social_media_service_name" => account.service_name,
          "url" => account.url,
          "title" => account.display_name,
        }
      end,
    }
  end

  def ignore_legacy_content_fields(content)
    # we're not carrying over duration fields to new topical events
    content[:details].delete(:start_date)
    content[:details].delete(:end_date)
    if content[:details][:ordered_featured_documents]
      content[:details][:ordered_featured_documents].each do |featured_document|
        # Deleting as the value is changed in the StandardEdition equivalent
        featured_document[:image].delete(:url)
      end
    end
    content
  end

  def ignore_new_content_fields(content)
    content.delete(:auth_bypass_ids) # these were not present on legacy topical events and are included by default on StandardEdition
    content.delete(:links) # legacy Topical Events had no edition links, but StandardEdition ones will
    if content[:details][:ordered_featured_documents]
      # Delete medium_resolution_url and high_resolution_url in each feature in ordered_featured_documents - these are new optional extra image variants in the StandardEdition featuring equivalent
      content[:details][:ordered_featured_documents].each do |featured_document|
        # Deleting as these are new values in the StandardEdition equivalent
        featured_document[:image].delete(:medium_resolution_url)
        featured_document[:image].delete(:high_resolution_url)

        # Deleting as the value is changed in the StandardEdition equivalent
        featured_document[:image].delete(:url)
      end
    end
    content
  end

  def ignore_legacy_links(links)
    links
  end

  def ignore_new_links(links)
    links
  end
end
