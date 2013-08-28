class AnnouncementPresenter < Whitehall::Decorators::Decorator
  include EditionPresenterHelper

  delegate_instance_methods_of *Announcement.concrete_descendants

  def as_hash
    super.merge({
      field_of_operation: field_of_operation,
      publication_series: publication_series
    })
  end

  def field_of_operation
    if model.respond_to?(:operational_field) && model.operational_field.present?
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
