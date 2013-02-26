class Api::DetailedGuidePresenter < Draper::Base
  class << self
    def paginate(collection)
      page = Api::Paginator.paginate(collection, h.params)
      Api::PagePresenter.new decorate(page)
    end
  end

  def as_json(options = {})
    data = {
      title: model.title,
      id: detailed_guide_url(model),
      web_url: h.public_document_url(model),
      details: {
        body: h.bare_govspeak_edition_to_html(model)
      },
      format: model.format_name,
      related: related_json,
      tags: organisation_tags(model)
    }
  end

  private

  def organisation_tags(model)
    model.organisations.collect do |org|
      {
        title: org.name,
        id: h.organisation_url(org, format: :json),
        web_url: h.organisation_url(org),
        details: {
          type: "organisation",
          short_description: org.acronym
        }
      }
    end
  end

  def detailed_guide_url(guide)
    h.api_detailed_guide_url guide.document, host: h.public_host
  end

  def related_json
    model.published_related_detailed_guides.map do |guide|
      {
        id: detailed_guide_url(guide),
        title: guide.title,
        web_url: h.public_document_url(guide)
      }
    end
  end
end
