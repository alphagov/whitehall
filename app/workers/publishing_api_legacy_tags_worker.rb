class PublishingApiLegacyTagsWorker
  API = Services.publishing_api

  def perform(edition_id, taxon_ids)
    taxon_tree_ids = taxon_ids + taxon_ids.flat_map do |taxon_id|
      get_taxon_parent_ids(taxon_id)
    end

    legacy_ids = API.get_links_for_content_ids(taxon_tree_ids)
      .values.flat_map { |ls| ls["links"].fetch("legacy_taxons", []) }

    edition = Edition.find(edition_id)
    links = {}

    if edition.respond_to?(:policy_content_ids)
      links[:policies] = Policy.all.map(&:content_id) & legacy_ids
    end

    if edition.respond_to?(:specialist_sector_tags)
      topics = API.get_linkables(document_type: 'topic')
        .to_a.map { |topic| topic["content_id"] } & legacy_ids

      links[:topics] = topics
    end

    if edition.respond_to?(:topics)
      policy_areas = Topic.where(content_id: legacy_ids)
      links[:policy_areas] = policy_areas.map(&:content_id)
    end

    API.patch_links(edition.content_id, links: links)
  end

  private

  def get_taxon_parent_ids(taxon_id)
    parent = API.get_expanded_links(taxon_id)["expanded_links"]
      .fetch("parent_taxons", []).first

    parent_ids = []

    while parent
      parent_ids << parent["content_id"]
      parent = parent["links"].fetch("parent_taxons", []).first
    end

    parent_ids
  end
end
