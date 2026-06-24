class StandardEditionMigrator::TopicalEventRecipe < StandardEditionMigrator::BaseRecipe
  include GovspeakHelper

  def initialize
    @artefacts_to_save = []
    super
  end

  def legacy_presenter
    PublishingApi::TopicalEventPresenter
  end

  def build_edition(record)
    raise WhitehallError, "Topical Events with About pages are not currently supported by the migrator" if record.topical_event_about_page

    attributes = {
      creator: User.find_by(name: "Scheduled Publishing Robot"),
      created_at: record.created_at,
      updated_at: record.updated_at,
      configurable_document_type: "topical_event",
      title: record.name,
      summary: record.summary,
      slug_override: record.slug,
      block_content: {
        # A body is now required, and we don't want to loosen the validation on new topical events
        "body" => record.description || "&nbsp;",
        "social_media_links" => social_media_links(record),
      },
      lead_organisations: record.topical_event_organisations.where(lead: true).order(:lead_ordering).map(&:organisation),
      supporting_organisations: record.topical_event_organisations.where(lead: false).map(&:organisation),
      feature_lists: [feature_list(record)],
      images: [logo(record)].compact,
      state: "published",
      # we can't know that the `updated_at` was a major change; all we can guarantee
      # is that the initial publication was a major change.
      major_change_published_at: record.created_at,
    }
    StandardEdition.new(attributes)
  end

  def after_save_edition(edition, legacy_record)
    # Save the in-memory artefacts that were built during edition creation (e.g. FeatureList, Image, etc.)
    @artefacts_to_save.each do |artefact|
      if artefact.respond_to?(:edition_id=)
        artefact.edition_id = edition.id
      end
      artefact.save!
    end
    # Create and save the associations that rely on Edition being a persisted record.
    legacy_record.topical_event_memberships.each do |membership|
      EditionLink.create!(
        edition_id: membership.edition_id,
        document_id: edition.document_id,
        link_type: "topical_event",
      )
    end
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

      # 'image' (logo) is replaced by 'images'
      content[:details].delete(:image)
    end

    if content[:details] && content[:details][:body] == "<div class=\"govspeak\">\n</div>"
      content[:details][:body] = "<div class=\"govspeak\"><p>&nbsp;</p>\n</div>"
    end

    if content[:details] && content[:details][:ordered_featured_documents]
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

    # convert public_timestamp to a string in the same format as the StandardEdition equivalent
    content[:public_updated_at] = content[:public_updated_at].rfc3339 if content[:public_updated_at].respond_to?(:rfc3339)
    content
  end

  def ignore_new_content_fields(content)
    content.delete(:auth_bypass_ids) # these were not present on legacy topical events and are included by default on StandardEdition
    content.delete(:links) # legacy Topical Events had no edition links, but StandardEdition ones will

    if content[:details] && content[:details][:ordered_featured_documents]
      # Delete medium_resolution_url and high_resolution_url in each feature in ordered_featured_documents - these are new optional extra image variants in the StandardEdition featuring equivalent
      content[:details][:ordered_featured_documents].each do |featured_document|
        # Deleting as these are new values in the StandardEdition equivalent
        featured_document[:image].delete(:medium_resolution_url)
        featured_document[:image].delete(:high_resolution_url)

        # Deleting as the value is changed in the StandardEdition equivalent
        featured_document[:image].delete(:url)
      end
    end

    if content[:details] && content[:details][:social_media_links]
      content[:details][:social_media_links].each do |social_media_link|
        social_media_link[:title] = social_media_link[:title].gsub(/\s+\(\d+\)$/, "") # Remove the "(1)" or "(2)" suffixes that are added in the StandardEdition equivalent
      end
    end

    # Delete the 'images' array (replacing old 'image' property)
    content[:details].delete(:images) if content[:details]
    content
  end

  def ignore_new_links(links)
    links.delete(:emphasised_organisations) # these are not present on legacy topical events and are included by default on StandardEdition
    links
  end

private

  def social_media_links(record)
    services = {}
    record.social_media_accounts.map do |account|
      services[account.service_name] ||= []
      services[account.service_name] << account.url
      title = services[account.service_name].count > 1 ? "#{account.display_name} (#{services[account.service_name].count})" : account.display_name

      {
        "social_media_service_name" => account.service_name,
        "url" => account.url,
        "title" => title,
      }
    end
  end

  def feature_list(record)
    feature_list = FeatureList.new(locale: "en")
    feature_list.features = record.topical_event_featurings.order(:ordering).map.with_index do |featuring, index|
      featured_image = FeaturedImageData.new(
        carrierwave_image: featuring.image.carrierwave_image,
      )
      featuring.image.assets.each do |asset|
        duplicated_asset = asset.dup
        duplicated_asset.assetable = featured_image
        featured_image.assets << duplicated_asset
      end

      attrs = {
        image: featured_image,
        alt_text: featuring.alt_text,
        ordering: index + 1,
      }
      if featuring.offsite_link
        attrs[:offsite_link] = featuring.offsite_link
      else
        attrs[:document] = featuring.edition.document
      end
      Feature.new(attrs)
    end

    @artefacts_to_save << feature_list
    feature_list
  end

  def logo(record)
    return unless record.logo

    # We grab the s960 variant because there are some cases where the original
    # asset is actually smaller than 960, and the s960 variant has then been upscaled.
    s960_logo_asset = record.logo.assets.find { |asset| asset.variant == "s960" }
    s960_logo_filename = s960_logo_asset&.filename || record.logo.filename

    unless s960_logo_asset&.asset_manager_id.present? && s960_logo_filename.present?
      raise WhitehallError, "Topical Event logo cannot be migrated because the legacy s960 logo asset is incomplete"
    end

    image_data = ImageData.new(
      image_kind: "topical_event_logo",
      # We lie below - just to make it 'valid'.
      # If the publisher ever wants to edit the logo, they'll likely need to upload a new one.
      crop_data: {
        x: 0,
        y: 0,
        width: 1506,
        height: 1004,
      },
      dimensions: {
        "width": 1506,
        "height": 960,
      },
    )
    image_data.save!(validate: false)

    # Set the uploader identifier after create so before_create doesn't try to
    # probe image dimensions via MiniMagick for a file we are not downloading.
    image_data.update_column(:carrierwave_image, s960_logo_filename)

    variants = %w[
      original
      topical_event_logo_mobile
      topical_event_logo_mobile_2x
      topical_event_logo_tablet
      topical_event_logo_tablet_2x
      topical_event_logo_desktop
      topical_event_logo_desktop_2x
    ]
    variants.each do |variant|
      image_data.assets.create!(
        variant: variant,
        asset_manager_id: s960_logo_asset.asset_manager_id,
        filename: s960_logo_filename,
      )
    end

    image = Image.create!(
      usage: "logo",
      image_data: image_data,
    )

    # Assets and ImageData are already persisted above; re-saving ImageData can
    # clobber the mounted uploader identifier and lead to nil URLs in payloads.
    # So deliberately don't save ImageData or its Assets again.
    @artefacts_to_save << image
    image
  end
end
