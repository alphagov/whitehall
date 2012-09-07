class Api::SpecialistGuidePresenter < Draper::Base
  def as_json(options = nil)
    {
      title: model.title,
      web_url: h.specialist_guide_url(model.document),
      details: {
        body: h.govspeak_edition_to_html(model),
        organisations: model.organisations.map(&:name)
      },
      related_artefacts: related_artefacts_json
    }
  end

  private

  def related_artefacts_json
    model.published_related_specialist_guides.map do |guide|
      {title: guide.title, web_url: h.specialist_guide_url(guide.document)}
    end
  end
end