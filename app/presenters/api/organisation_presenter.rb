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
        acronym: model.acronym,
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
        web_url: context.organisation_url(parent)
      }
    end
  end

  def child_organisations
    model.child_organisations.map do |child|
      {
        id: context.api_organisation_url(child),
        web_url: context.organisation_url(child)
      }
    end
  end
end
