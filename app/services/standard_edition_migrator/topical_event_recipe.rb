class StandardEditionMigrator::TopicalEventRecipe < StandardEditionMigrator::BaseRecipe
  include GovspeakHelper

  attr_reader :artefacts_to_save

  def build_edition(record)
    @artefacts_to_save = [] # set here just in case we called this once already e.g. for preview
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
      configurable_document_type: "topical_event",
      state: "published",
      slug: record.slug,
      updated_at: record.updated_at.rfc3339,
      first_published_at: record.created_at.rfc3339,
      major_change_published_at: record.updated_at.rfc3339,
      feature_lists: feature_lists,
      # We're only importing a single 'flattened' edition
      # from Content Publisher. This doesn't play nicely with the
      # Edition model's `set_public_timestamp` callback, which checks
      #  if this is the "first published version" (defined in `Edition::Publishing`),
      # which is true if `published_major_version` is `nil` or `1`.
      # It would then set `public_timestamp` to `first_published_at`,
      # which is not the correct timestamp if there was a subsequent
      # major version.
      # By setting `published_major_version` to a minimum of `2`, the
      # `set_public_timestamp` falls back to `major_change_published_at`,
      # which we've set to match the latest public changenote timestamp
      # associated with the edition, which is the correct value.
      published_major_version: 2,
      # TODO: add an internal note too, indicating the date of the migraton.
    }
    attributes[:public_timestamp] = record.public_timestamp if record.respond_to?(:public_timestamp)

    user = User.find_by(name: "Scheduled Publishing Robot")
    edition = nil
    AuditTrail.acting_as(user) do
      edition = StandardEdition.new(attributes)
      edition.creator = user
    end

    raise WhitehallError, "Topical Events with About pages are not currently supported by the migrator" if record.topical_event_about_page
    edition.translations.find_or_initialize_by(locale: "en").update(
      title: title(record),
      summary: summary(record),
      block_content: {
        "body" => record.description,
        "social_media_links" => record.social_media_accounts.map do |account|
          {
            "social_media_service_name" => account.service_name,
            "url" => account.url,
            "title" => account.display_name,
          }
        end,
      }
    )

    edition.lead_organisations = record.topical_event_organisations.where(lead: true).map(&:organisation)
    edition.supporting_organisations = record.topical_event_organisations.where(lead: false).map(&:organisation)

    @artefacts_to_save = {
      document: document,
      edition: edition,
      everything_else: edition.translations,
    }
    @artefacts_to_save[:everything_else] += features.flat_map(&:image).flat_map(&:assets)
    @artefacts_to_save[:everything_else] += features
    @artefacts_to_save[:everything_else] += feature_lists

    if record.logo
      new_logo_data = ImageData.new(
        carrierwave_image: record.logo.carrierwave_image,
        image_kind: "topical_event_logo",
      )

      # include all derived variants
      new_logo_data.file.active_version_names.each do |version_name|
        new_logo_data.assets.build(
          variant: version_name,
          filename: record.logo.filename,
          asset_manager_id: record.logo.assets.first&.asset_manager_id,
        )
      end

      # ⚠️ critical: original must exist explicitly
      new_logo_data.assets.build(
        variant: :original,
        filename: record.logo.filename,
        asset_manager_id: record.logo.assets.first&.asset_manager_id,
      )

      new_logo = edition.images.build(
        image_data: new_logo_data,
        usage: "logo",
      )

      @artefacts_to_save[:everything_else] += [new_logo, new_logo_data]
    end

    @artefacts_to_save[:everything_else] = @artefacts_to_save[:everything_else].flatten
    edition
  end

  def save_built_edition!
    # First time around, save without validation, since some records are interdependent
    @artefacts_to_save[:document].save!(validate: false)
    @artefacts_to_save[:edition].save!(validate: false)
    @artefacts_to_save[:everything_else].each do |artefact|
      if artefact.respond_to?(:edition_id=)
        artefact.edition_id = @artefacts_to_save[:edition].id
      end
      artefact.save!(validate: false)
    end

    # Second time around, save with validation, to ensure all artefacts are valid (and to trigger any callbacks)
    @artefacts_to_save[:document].save!
    @artefacts_to_save[:edition].save!
    @artefacts_to_save[:everything_else].each(&:save!)
  end

  def legacy_presenter
    PublishingApi::TopicalEventPresenter
  end

  def title(legacy_topical_event)
    legacy_topical_event.name
  end

  def summary(legacy_topical_event)
    legacy_topical_event.summary
  end

  def ignore_legacy_content_fields(content)
    # drop .atom routes - they're not supported anymore
    if content[:routes]
      content[:routes] = content[:routes].reject { |route| route[:path].end_with?(".atom") }
    end
    if content[:details]
      # we're not carrying over duration fields to new topical events
      content[:details].delete(:start_date)
      content[:details].delete(:end_date)

      # remove image as it has been replaced by images
      content[:details].delete(:image)

      if content[:details][:ordered_featured_documents]
        content[:details][:ordered_featured_documents].each do |featured_document|
          if featured_document[:summary]
            # Remove stray spaces from end of the summary as that is what the StandardEdition equivalent does
            featured_document[:summary] = featured_document[:summary].gsub(/\s+$/, "")
            # Put through govspeak_to_html as that's what the StandardEdition equivalent does
            featured_document[:summary] = ActionView::Base.full_sanitizer.sanitize(govspeak_to_html(featured_document[:summary])).strip
          end
          if featured_document[:image]
            # Deleting as the value is changed in the StandardEdition equivalent
            featured_document[:image].delete(:url)
          end
        end
      end
    end

    # convert public_timestamp to a string in the same format as the StandardEdition equivalent
    content[:public_updated_at] = content[:public_updated_at].rfc3339 if content[:public_updated_at].respond_to?(:rfc3339)

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

    # remove images as it replaces 'image'
    content[:details].delete(:images)
    content
  end

  def ignore_legacy_links(links)
    links
  end

  def ignore_new_links(links)
    links.delete(:emphasised_organisations) # these are not present on legacy topical events and are included by default on StandardEdition
    links
  end
end
