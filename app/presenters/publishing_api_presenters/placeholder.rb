# For now, this is used to register data for items in the content
# store as "placeholder" content items. This is so that finders can reference
# items using content_ids and have their basic information expanded
# out when read back out from the content store.
class PublishingApiPresenters::Placeholder
  attr_reader :item, :update_type

  def initialize(item, options = {})
    @item = item
    @update_type = options[:update_type] || default_update_type
  end

  def base_path
    Whitehall.url_maker.polymorphic_path(item)
  end

  def as_json
    {
      content_id: item.content_id,
      title: item.name,
      format: format,
      locale: I18n.locale.to_s,
      publishing_app: 'whitehall',
      rendering_app: 'whitehall-frontend',
      public_updated_at: item.updated_at,
      routes: [
        {
          path: base_path,
          type: "exact"
        }
      ],
      update_type: update_type,
    }
  end

private
  def format
    "placeholder_#{item.class.name.underscore}"
  end

  def default_update_type
    "major"
  end
end
