require_relative "../publishing_api_presenters"

class PublishingApiPresenters::TakePart < PublishingApiPresenters::Item
  def links
    extract_links([
      :policy_areas,
    ])
  end

private

  def schema_name
    "take_part"
  end

  def details
    {
      body: body,
      image: {
        url: Whitehall.public_asset_host + item.image_url(:s300),
        alt_text: item.image_alt_text,
      }
    }
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
