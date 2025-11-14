class StandardEditionMigrator::NewsArticleRecipe
  def configurable_document_type
    raise "NewsArticleRecipe should not be used directly. Use a subtype recipe instead."
  end

  def presenter
    PublishingApi::NewsArticlePresenter
  end

  def map_legacy_fields_to_block_content(edition, translation)
    {
      "body" => translation.body,
      # Translations always inherit the lead image set on the primary locale.
      # Post migration, translations can have their lead image updated independently.
      "image" => edition.lead_image&.image_data_id,
    }
  end

  def ignore_legacy_content_fields(content)
    content[:details].delete(:first_public_at)
    content[:details][:image]&.delete(:alt_text)
    if content[:details][:image] && content[:details][:image][:caption].nil?
      content[:details][:image]&.delete(:caption)
    end
    if content[:details][:tags]
      if content[:details][:tags].keys == [:browse_pages]
        content[:details].delete(:tags)
      else
        content[:details][:tags].delete(:browse_pages)
      end
    end
    content
  end

  def ignore_new_content_fields(content)
    content.delete(:links)
    content
  end

  def ignore_legacy_links(links)
    links.delete(:original_primary_publishing_organisation)
    links.delete(:worldwide_organisations)
    links
  end

  def ignore_new_links(links)
    links
  end
end
