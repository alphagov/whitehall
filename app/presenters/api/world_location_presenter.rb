class Api::WorldLocationPresenter < Api::BasePresenter
  def as_json(_options = {})
    {
      id: context.api_world_location_url(model),
      title: model.name,
      format: model.display_type,
      updated_at: model.updated_at,
      web_url: Whitehall.url_maker.world_location_url(model),
      analytics_identifier: model.analytics_identifier,
      details: {
        slug: model.slug,
        iso2: model.iso2,
      },
      organisations: {
        id: context.api_world_location_worldwide_organisations_url(model),
        web_url: Whitehall.url_maker.world_location_url(model, anchor: "organisations"),
      },
      content_id: model.content_id,
      england_coronavirus_travel: england_coronavirus_travel,
    }
  end

  def links
    [
      [context.api_world_location_url(model), { "rel" => "self" }],
    ]
  end

  def england_coronavirus_travel
    {
      rag_status: model.coronavirus_rag_status,
      required_tests: model.coronavirus_required_tests,
    }
  end
end
