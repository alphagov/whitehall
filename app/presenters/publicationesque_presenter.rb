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

  def time_until_closure
    days_left = model.closing_on - Time.zone.now.to_date
    case days_left
    when ->(n) {n < 0}
      "Closed"
    when 0
      "Closing today"
    when 1
      "Closes tomorrow"
    else
      "#{days_left.to_i} days left"
    end
  end
end
