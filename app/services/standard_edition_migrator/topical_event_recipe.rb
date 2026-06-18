class StandardEditionMigrator::TopicalEventRecipe < StandardEditionMigrator::BaseRecipe
  include GovspeakHelper

  def legacy_presenter
    PublishingApi::TopicalEventPresenter
  end

  def build_edition(record)
    raise WhitehallError, "Topical Events with About pages are not currently supported by the migrator" if record.topical_event_about_page

    attributes = {
      created_at: record.created_at,
      updated_at: record.updated_at,
      configurable_document_type: "topical_event",
      title: record.name,
      summary: record.summary,
      slug_override: record.slug,
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
      lead_organisations: record.topical_event_organisations.where(lead: true).map(&:organisation),
      supporting_organisations: record.topical_event_organisations.where(lead: false).map(&:organisation),
      feature_lists: [feature_list(record)],
    }
    StandardEdition.new(attributes)
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

    content
  end

  def ignore_new_links(links)
    links.delete(:emphasised_organisations) # these are not present on legacy topical events and are included by default on StandardEdition
    links
  end

private

  def feature_list(record)
    feature_list = FeatureList.new(locale: "en")
    feature_list.features = record.topical_event_featurings.map do |featuring|
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
        ordering: featuring.ordering,
      }
      if featuring.offsite_link
        attrs[:offsite_link] = featuring.offsite_link
      else
        attrs[:document] = featuring.edition.document
      end
      Feature.new(attrs)
    end

    queue_for_saving(feature_list)
    feature_list
  end
end
