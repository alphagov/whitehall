require_relative "../publishing_api_presenters"

class PublishingApiPresenters::DetailedGuide < PublishingApiPresenters::Edition
  def links
    extract_links [
      :lead_organisations,
      :related_guides
    ]
  end

private

  def document_format
    "detailed_guide"
  end

  def details
    super.merge(
      body: body,
      first_public_at: first_public_at,
      change_history: item.change_history.as_json
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
end
