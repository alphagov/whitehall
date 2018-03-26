module Taxonomy::AssociationsTranslation
  def self.mapped_taxon_content_ids_for_edition(edition)
    [
      # This method still uses the legacy "specialist sectors" name
      edition.specialist_sectors,
      # topics means policy areas in this context
      (edition.topics if edition.can_be_associated_with_topics?),
      (edition.policies if edition.can_be_related_to_policies?)
    ].compact.flatten.flat_map do |legacy_taxon|
      content_ids = fetch_topic_taxonomy_taxons_content_ids(
        legacy_taxon.content_id
      )

      log_mapping(legacy_taxon, content_ids)

      content_ids
    end
  end

  def self.fetch_topic_taxonomy_taxons_content_ids(content_id)
    expanded_links = Services.publishing_api.get_expanded_links(
      content_id
    ).to_hash['expanded_links']

    expanded_links.fetch('topic_taxonomy_taxons', []).map do |taxon|
      taxon['content_id']
    end
  end

  def self.log_mapping(legacy_taxon, mapped_content_ids)
    prefix =
      "#{name}: #<#{legacy_taxon.class.name} "\
      "#{legacy_taxon.try(:title) || ''}:"\
      "#{legacy_taxon.content_id}>"

    if mapped_content_ids.any?
      logger.info "#{prefix} maps to #{mapped_content_ids.join(', ')}"
    else
      logger.info "#{prefix} is missing topic_taxonomy_taxons"
    end
  end
end
