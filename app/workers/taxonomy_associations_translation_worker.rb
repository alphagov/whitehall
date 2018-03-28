class TaxonomyAssociationsTranslationWorker < WorkerBase
  sidekiq_options queue: 'publishing_api'

  def perform(model_name, id)
    model = class_for(model_name).unscoped.find(id)
    return if model.nil?

    taxon_content_ids = taxon_content_ids_for_model(model)
    return if taxon_content_ids.nil?

    Services.publishing_api.patch_links(
      edition.content_id,
      links: {
        taxons: taxon_content_ids
      }
    )
  end

private

  def class_for(model_name)
    model_name.constantize
  end

  def taxon_content_ids_for_model(model)
    if model.is_a?(Edition)
      applicable_taxon_content_ids_for_edition(model)
    elsif model.try(:can_publish_to_publishing_api?)
      applicable_taxon_content_ids_for_links(model)
    end
  end

  def applicable_taxon_content_ids_for_edition(edition)
    taxon_content_ids =
      Taxonomy::AssociationsTranslation
        .mapped_taxon_content_ids_for_edition(edition)

    logger.info(
      "#{self.class.name}: #{edition.content_id} taxons: "\
      "#{taxon_content_ids.join(' ,')}"
    )

    taxon_content_ids
  end

  def applicable_taxon_content_ids_for_links(model)
    presenter = PublishingApiPresenters.presenter_for(model)

    taxon_content_ids =
      Taxonomy::AssociationsTranslation
        .mapped_taxon_content_ids_for_links(presenter.links)

    logger.info(
      "#{self.class.name}: #{presenter.content_id} taxons: "\
      "#{taxon_content_ids.join(' ,')}"
    )

    taxon_content_ids
  end
end
