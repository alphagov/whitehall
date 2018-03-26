class TaxonomyAssociationsTranslationWorker < WorkerBase
  sidekiq_options queue: 'publishing_api'

  def perform(model_name, id)
    edition = class_for(model_name).unscoped.find(id)
    return if edition.nil?

    Services.publishing_api.patch_links(
      edition.content_id,
      links: {
        taxons: applicable_taxon_content_ids(edition)
      }
    )
  end

private

  def class_for(model_name)
    model_name.constantize
  end

  def applicable_taxon_content_ids(edition)
    taxon_content_ids =
      Taxonomy::AssociationsTranslation
        .mapped_taxon_content_ids_for_edition(edition)

    logger.info(
      "#{self.class.name}: #{edition.content_id} taxons: "\
      "#{taxon_content_ids.join(' ,')}"
    )

    taxon_content_ids
  end
end
