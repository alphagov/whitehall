class StandardEditionMigrator::CaseStudyRecipe
  def initialize(edition)
    @edition = edition
  end

  def configurable_document_type
    "case_study"
  end

  def presenter
    PublishingApi::CaseStudyPresenter
  end

  def map_legacy_fields_to_block_content(translation)
    {
      "body" => translation.body,
    }
  end

  def ignore_legacy_content_fields(content)
    content[:details].delete(:first_public_at)
    content[:details].delete(:image)
    content[:details].delete(:tags)
    content[:details].delete(:format_display_type)
    content[:public_updated_at] = content[:public_updated_at].rfc3339

    if content[:details][:change_history].empty?
      content[:details].delete(:change_history)
    end

    if content[:details][:body]
      content[:details][:body] = content[:details][:body].gsub(/\n\s*\n/, "\n")
    end

    content
  end

  def ignore_new_content_fields(content)
    content.delete(:first_published_at)
    content[:details].delete(:images)
    content[:details].delete(:attachments)
    content.delete(:links)
    if content[:details][:body]
      content[:details][:body] = content[:details][:body]
        .gsub(%r{\s*<p class="gem-c-attachment__metadata">This file may not be suitable for users of assistive technology\.</p>\s*<details[^>]*>.*?</details>}m, "")
        .gsub(/\n\s*\n/, "\n")
    end
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
