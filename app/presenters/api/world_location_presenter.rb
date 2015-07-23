class Api::WorldLocationPresenter < Api::BasePresenter
  def as_json(options = {})
    {
      id: context.api_world_location_url(model),
      title: model.name,
      format: model.display_type,
      updated_at: model.updated_at,
      web_url: Whitehall.url_maker.world_location_url(model),
      details: {
        slug: model.slug,
        iso2: model.iso2,
        analytics_identifier: model.analytics_identifier,
      },
      organisations: {
        id: context.api_world_location_worldwide_organisations_url(model),
        web_url: Whitehall.url_maker.world_location_url(model, anchor: 'organisations'),
      }
    }
  end

  def links
    [
      [context.api_world_location_url(model), {'rel' => 'self'}]
    ]
  end
end
