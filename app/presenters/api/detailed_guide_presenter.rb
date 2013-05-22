class Api::DetailedGuidePresenter < Api::BasePresenter
  def as_json(options = {})
    {
      title: model.title,
      id: detailed_guide_url(model),
      web_url: context.public_document_url(model),
      details: {
        body: context.bare_govspeak_edition_to_html(model)
      },
      format: model.format_name,
      related: related_json,
      tags: organisation_tags(model)
    }
  end

  def links
    [
      [detailed_guide_url(model), {'rel' => 'self'}]
    ]
  end

  private

  def organisation_tags(model)
    model.organisations.map do |org|
      {
        title: org.name,
        id: context.organisation_url(org, format: :json),
        web_url: context.organisation_url(org),
        details: {
          type: "organisation",
          short_description: org.acronym
        }
      }
    end
  end

  def detailed_guide_url(guide)
    context.api_detailed_guide_url guide.document, host: context.public_host
  end

  def related_json
    model.published_related_detailed_guides.map do |guide|
      {
        id: detailed_guide_url(guide),
        title: guide.title,
        web_url: context.public_document_url(guide)
      }
    end
  end
end
