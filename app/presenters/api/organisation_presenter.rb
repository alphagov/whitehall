class Api::OrganisationPresenter < Api::BasePresenter
  def as_json(options = {})
    {
      id: context.api_organisation_url(model),
      title: model.name,
      format: model.organisation_type.name,
      updated_at: model.updated_at,
      web_url: Whitehall.url_maker.organisation_url(model),
      short_urls: model.short_urls,
      details: {
        slug: model.slug,
        abbreviation: model.acronym,
        logo_formatted_name: model.logo_formatted_name,
        organisation_brand_colour_class_name: model.organisation_brand_colour.try(:class_name),
        organisation_logo_type_class_name: model.organisation_logo_type.try(:class_name),
        closed_at: model.closed_at,
        govuk_status: model.govuk_status,
      },
      parent_organisations: parent_organisations,
      child_organisations: child_organisations,
    }
  end

  def links
    [
      [context.api_organisation_url(model), {'rel' => 'self'}]
    ]
  end

private
  def parent_organisations
    model.parent_organisations.map do |parent|
      {
        id: context.api_organisation_url(parent),
        web_url: Whitehall.url_maker.organisation_url(parent)
      }
    end
  end

  def child_organisations
    model.child_organisations.map do |child|
      {
        id: context.api_organisation_url(child),
        web_url: Whitehall.url_maker.organisation_url(child)
      }
    end
  end
end
