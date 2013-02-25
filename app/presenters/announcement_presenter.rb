class AnnouncementPresenter < Draper::Base
  include EditionPresenterHelper

  decorates :announcement

  def as_hash
    super.merge({
      field_of_operation: field_of_operation,
      publication_series: publication_series
    })
  end

  def field_of_operation
    if model.respond_to?(:operational_field)
      "Field of operation: #{h.link_to(model.operational_field.name, model.operational_field)}"
    end
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
