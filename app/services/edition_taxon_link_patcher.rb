class EditionTaxonLinkPatcher
  def call(model:, previous_version:, selected_taxons:, invisible_taxons:)
    taxons = most_specific_taxons(selected_taxons) + invisible_taxons

    Services.publishing_api.patch_links(
      model.content_id, links: { taxons: taxons }, previous_version: previous_version
    )

    PublishingApiLegacyTagsWorker.perform_async(model.id, model.class.name)
  end

private

  def most_specific_taxons(selected_taxons)
    all_taxons.each_with_object([]) do |taxon, list_of_taxons|
      content_ids = taxon.descendants.map(&:content_id)

      any_descendants_selected = selected_taxons.any? do |selected_taxon|
        content_ids.include?(selected_taxon)
      end

      unless any_descendants_selected
        content_id = taxon.content_id
        list_of_taxons << content_id if selected_taxons.include?(content_id)
      end
    end
  end

  def all_taxons
    Taxonomy::GovukTaxonomy.new.all_taxons
  end
end
