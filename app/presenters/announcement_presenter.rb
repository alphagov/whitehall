class AnnouncementPresenter < Struct.new(:model, :context)
  include EditionPresenterHelper

  announcement_methods = Announcement.concrete_descendants.map(&:instance_methods).flatten.uniq - Object.instance_methods
  delegate *announcement_methods, to: :model

  def as_hash
    super.merge({
      field_of_operation: field_of_operation,
      publication_series: publication_series
    })
  end

  def field_of_operation
    if model.respond_to?(:operational_field)
      "Field of operation: #{context.link_to(model.operational_field.name, model.operational_field)}"
    end
  end

  def publication_series
    if model.respond_to?(:part_of_series?) && model.part_of_series?
      links = model.document_series.map do |ds|
        context.link_to(ds.name, context.organisation_document_series_path(ds.organisation, ds))
      end
      "Part of a series: #{links.to_sentence}"
    end
  end
end
