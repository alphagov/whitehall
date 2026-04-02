class StandardEditionMigrator::CaseStudyRecipe
  def configurable_document_type
    "case_study"
  end

  def presenter
    PublishingApi::CaseStudyPresenter
  end

  def map_legacy_fields_to_block_content(_edition, translation)
    {
      "body" => translation.body,
    }
  end

  def ignore_legacy_content_fields(content)
    content[:first_published_at] = content[:details].delete(:first_public_at)
    content[:details].delete(:image)
    content[:details].delete(:tags)
    content[:details].delete(:format_display_type)
    content[:public_updated_at] = content[:public_updated_at].rfc3339
    content
  end

  def ignore_new_content_fields(content)
    content[:details].delete(:images)
    content[:details].delete(:attachments)
    content.delete(:links)
    content
  end

  def ignore_legacy_links(links)
    links
  end

  def ignore_new_links(links)
    links.delete(:government)
    links.delete(:emphasised_organisations)
    links
  end
end
