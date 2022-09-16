class AnnouncementPresenter < Whitehall::Decorators::Decorator
  include EditionPresenterHelper

  delegate_instance_methods_of(*Announcement.concrete_descendants)

  def as_hash
    super.merge(
      field_of_operation:,
      publication_collections:,
    )
  end

  def field_of_operation
    if model.respond_to?(:operational_field) && model.operational_field.present?
      "#{I18n.t('support.field_of_operation')} #{context.link_to(model.operational_field.name, model.operational_field, class: 'govuk-link')}"
    end
  end

  def publication_collections
    if model.respond_to?(:part_of_published_collection?) && model.part_of_published_collection?
      links = model.published_document_collections.map do |dc|
        context.link_to(dc.title, context.public_document_path(dc))
      end
      "#{I18n.t('support.part_of_collection')} #{links.to_sentence}"
    end
  end
end
