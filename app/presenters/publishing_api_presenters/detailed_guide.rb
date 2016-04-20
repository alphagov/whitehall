require_relative "../publishing_api_presenters"

class PublishingApiPresenters::DetailedGuide < PublishingApiPresenters::Edition
  def links
    extract_links([
      :lead_organisations
    ]).merge(
      related_guides: related_guides,
      related_mainstream: related_mainstream
    )
  end

private

  def document_format
    "detailed_guide"
  end

  def details
    super.merge(
      body: body,
      first_public_at: first_public_at,
      change_history: item.change_history.as_json,
      related_mainstream_content: related_mainstream
    )
  end

  def body
    Whitehall::GovspeakRenderer.new.govspeak_edition_to_html(item)
  end

  def first_public_at
    if item.document.published?
      item.first_public_at
    else
      item.document.created_at.iso8601
    end
  end

  def related_guides
    # TODO: Return real related guide content_ids.
    []
  end

  def related_mainstream
    base_paths = []
    base_paths.push(item.related_mainstream_base_path)
    base_paths.push(item.additional_related_mainstream_base_path)
    base_paths.compact!

    if base_paths.any?
      Whitehall.publishing_api_v2_client
        .lookup_content_ids(base_paths: base_paths)
        .values
        .compact
    else
      []
    end
  end
end
