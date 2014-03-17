class Api::OrganisationPresenter < Api::BasePresenter
  def as_json(options = {})
    {
      id: context.api_organisation_url(model),
      title: model.name,
      format: model.organisation_type.name,
      updated_at: model.updated_at,
      web_url: context.organisation_url(model, host: context.public_host),
      details: {
        slug: model.slug,
        abbreviation: model.acronym,
        logo_formatted_name: model.logo_formatted_name,
        organisation_brand_colour_class_name: model.organisation_brand_colour.try(:class_name),
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
        web_url: context.organisation_url(parent, host: context.public_host)
      }
    end
  end

  def child_organisations
    model.child_organisations.map do |child|
      {
        id: context.api_organisation_url(child),
        web_url: context.organisation_url(child, host: context.public_host)
      }
    end
  end
end
