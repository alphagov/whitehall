class Api::WorldLocationPresenter < Draper::Base
  class << self
    def paginate(collection)
      page = Api::Paginator.paginate(collection, h.params)
      Api::PagePresenter.new decorate(page)
    end
  end

  def as_json(options = {})
    {
      id: h.api_world_location_url(model, host: h.public_host),
      title: model.name,
      format: model.display_type,
      updated_at: model.updated_at,
      web_url: h.world_location_url(model, host: h.public_host),
      details: {
        slug: model.slug,
        iso2: model.iso2,
      },
      organisations: {
        id: h.api_world_location_worldwide_organisations_url(model, host: h.public_host),
        web_url: h.world_location_url(model, host: h.public_host, anchor: 'organisations'),
      }
    }
  end

  def links
    [
      [h.api_world_location_url(model, host: h.public_host), {'rel' => 'self'}]
    ]
  end
end
