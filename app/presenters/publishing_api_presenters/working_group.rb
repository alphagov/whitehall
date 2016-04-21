# Presents a `PolicyGroup` model.
class PublishingApiPresenters::WorkingGroup < PublishingApiPresenters::Item
  def links
    {}
  end

private

  def title
    item.name
  end

  def document_format
    "working_group"
  end

  def description
    item.summary # This is deliberately the 'wrong' way around
  end

  def details
    {
      email: item.email,
      body: body,
    }
  end

  def body
    # It looks 'wrong' using the description as the body, but it isn't
    Whitehall::GovspeakRenderer.new.govspeak_with_attachments_to_html(item.description, item.attachments)
  end

  def public_updated_at
    item.updated_at
  end

  def rendering_app
    Whitehall::RenderingApp::GOVERNMENT_FRONTEND
  end
end
