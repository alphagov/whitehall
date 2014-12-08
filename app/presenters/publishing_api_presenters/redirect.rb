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
      publishing_app: 'whitehall',
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
