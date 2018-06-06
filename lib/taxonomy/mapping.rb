class Taxonomy::Mapping
  def initialize
    @all_taxons = Taxonomy::TopicTaxonomy.new.all_taxons
  end

  def legacy_mapping_for_taxons(taxon_content_ids)
    all_legacy_associations = taxon_content_ids
                                .flat_map do |taxon_content_id|
      legacy_mapping_for_taxon(taxon_content_id).values.flatten
    end

    all_legacy_associations.uniq do |legacy_association|
      legacy_association["content_id"]
    end
  end

  def legacy_mapping_for_taxon(start_taxon_content_id)
    start_taxon = @all_taxons.find do |taxon|
      taxon.content_id == start_taxon_content_id
    end

    document_types = %w(policy policy_area topic)
    result = start_taxon.legacy_mapping.slice(*document_types)

    document_types.each do |document_type|
      start_taxon.ancestors.each do |ancestor|
        # Look up through the ancestors to find a mapping for each
        # document_type, but stop once one is found

        result[document_type] = ancestor.legacy_mapping
                                  .fetch(document_type, [])

        break if result[document_type].present?
      end
    end

    result
  end
end
