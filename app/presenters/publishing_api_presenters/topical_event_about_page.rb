require_relative "../publishing_api_presenters"

class PublishingApiPresenters::TopicalEventAboutPage < PublishingApiPresenters::Item
  def links
    # about pages aren't tagged
    {
      parent: [item.topical_event.content_id]
    }
  end

private

  def document_format
    "topical_event_about_page"
  end

  def base_path
    Whitehall.url_maker.topical_event_about_pages_path(item.topical_event)
  end

  def details
    {
      body: body,
      read_more: item.read_more_link_text
    }
  end

  def title
    item.name
  end

  def description
    item.summary
  end

  def public_updated_at
    item.updated_at
  end

  def body
    Whitehall::GovspeakRenderer.new.govspeak_to_html(item.body)
  end

  def rendering_app
    Whitehall::RenderingApp::GOVERNMENT_FRONTEND
  end
end
