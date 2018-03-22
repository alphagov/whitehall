class PublishingApiLegacyTagsWorker
  API = Services.publishing_api

  def perform(edition_id, taxon_ids)
    taxon_tree_ids = taxon_ids + taxon_ids.flat_map do |taxon_id|
      get_taxon_parent_ids(taxon_id)
    end

    legacy_ids = API.get_links_for_content_ids(taxon_tree_ids)
      .values.flat_map { |ls| ls["links"].fetch("legacy_taxons", []) }

    edition = Edition.find(edition_id)
    links = { policy_areas: [], policies: [], topics: [] }

    if edition.respond_to?(:policy_content_ids)
      policies = Policy.all.map(&:content_id) & legacy_ids
      links[:policies] += policies

      edition.policy_content_ids = policies

      parent_policies = edition.policy_content_ids - policies
      links[:policy_areas] += parent_policies
    end

    if edition.respond_to?(:specialist_sector_tags)
      topics = API.get_linkables(document_type: 'topic')
        .to_a.map { |topic| topic["content_id"] } & legacy_ids

      links[:topics] += topics
      edition.primary_specialist_sector_tag = topics.first
      edition.secondary_specialist_sector_tags = topics.drop(1)
    end

    if edition.respond_to?(:topics)
      edition.topics = Topic.where(content_id: legacy_ids)
      links[:policy_areas] += edition.topics.map(&:content_id)
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
