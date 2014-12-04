class PublishingApiPresenters::Redirect
  attr_reader :item, :update_type

  def initialize(item, options = {})
    @item = item
    @update_type = options[:update_type] || default_update_type
  end

  def base_path
    Whitehall.url_maker.public_document_path(item)
  end

  def as_json
    {
      base_path: base_path,
      format: "redirect",
      locale: I18n.locale.to_s,
      publishing_app: 'whitehall',
      rendering_app: 'whitehall-frontend',
      public_updated_at: item.updated_at,
      redirects: [
        {
          path: base_path,
          type: "exact",
          destination: redirect_path
        }
      ],
      update_type: update_type,
    }
  end

private

  def redirect_path
    item.unpublishing.alternative_url.sub(Whitehall.public_root, '')
  end

  def default_update_type
    "major"
  end
end
