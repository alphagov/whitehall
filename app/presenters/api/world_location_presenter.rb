class Api::WorldLocationPresenter < Struct.new(:model, :context)
  class << self
    def paginate(collection, view_context)
      page = Api::Paginator.paginate(collection, view_context.params)
      presented = page.map { |item| new(item, view_context) }
      Api::PagePresenter.new(presented, view_context)
    end
  end

  def as_json(options = {})
    {
      id: context.api_world_location_url(model),
      title: model.name,
      format: model.display_type,
      updated_at: model.updated_at,
      web_url: context.world_location_url(model, host: context.public_host),
      details: {
        slug: model.slug,
        iso2: model.iso2,
      },
      organisations: {
        id: context.api_world_location_worldwide_organisations_url(model),
        web_url: context.world_location_url(model, host: context.public_host, anchor: 'organisations'),
      }
    }
  end

  def links
    [
      [context.api_world_location_url(model), {'rel' => 'self'}]
    ]
  end
end
