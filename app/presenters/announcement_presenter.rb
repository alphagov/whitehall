class AnnouncementPresenter < Whitehall::Decorators::Decorator
  include EditionPresenterHelper

  delegate_instance_methods_of *Announcement.concrete_descendants

  def as_hash
    super.merge({
      field_of_operation: field_of_operation,
      publication_collection: publication_collection
    })
  end

  def field_of_operation
    if model.respond_to?(:operational_field) && model.operational_field.present?
      "Field of operation: #{context.link_to(model.operational_field.name, model.operational_field)}"
    end
  end

  def publication_collection
    if model.respond_to?(:part_of_collection?) && model.part_of_collection?
      links = model.document_collections.map do |dc|
        context.link_to(dc.name, context.document_collection_path(dc))
      end
      "Part of a collection: #{links.to_sentence}"
    end
  end
end
