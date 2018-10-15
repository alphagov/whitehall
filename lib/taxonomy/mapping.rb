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

    result = start_taxon.legacy_mapping.slice('topic')

    start_taxon.ancestors.each do |ancestor|
      break if result['topic'].present?

      result['topic'] = ancestor.legacy_mapping.fetch('topic', [])
    end

    result
  end
end
