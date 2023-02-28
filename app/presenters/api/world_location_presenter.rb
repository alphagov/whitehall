class Api::WorldLocationPresenter < Api::BasePresenter
  def as_json(_options = {})
    {
      id: context.api_world_location_url(model),
      title: model.name,
      format: model.display_type,
      updated_at: model.updated_at,
      web_url: model.public_url(locale: I18n.default_locale),
      analytics_identifier: model.analytics_identifier,
      details: {
        slug: model.slug,
        iso2: model.iso2,
      },
      organisations: {
        id: context.api_world_location_worldwide_organisations_url(model),
        web_url: model.public_url({ anchor: "organisations" }, locale: I18n.default_locale),
      },
      content_id: model.content_id,
    }
  end

  def links
    [
      [context.api_world_location_url(model), { "rel" => "self" }],
    ]
  end
end
