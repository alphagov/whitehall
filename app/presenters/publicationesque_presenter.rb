class PublicationesquePresenter < Draper::Base
  include EditionPresenterHelper

  decorates :publicationesque

  def as_hash
    super.merge({
      publication_series: publication_series
    })
  end

  def publication_series
    if model.part_of_series?
      links = model.document_series.map do |ds|
        h.link_to(ds.name, h.organisation_document_series_path(ds.organisation, ds))
      end
      "Part of a series: #{links.to_sentence}"
    end
  end
end
