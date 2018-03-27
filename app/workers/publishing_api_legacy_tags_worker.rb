class PublishingApiLegacyTagsWorker
  include Sidekiq::Worker
  API = Services.publishing_api

  def perform(model_id, model_class)
    model = model_class.constantize.find(model_id)
    previous_version, taxon_ids = get_taxon_ids(model)
    parent_ids = taxon_ids.flat_map { |id| expand_parents(id) }
    legacy_ids = get_legacy_links(taxon_ids + parent_ids)

    links = { policy_areas: [], policies: [], topics: [] }
    update_topics(links, legacy_ids, model)
    update_policies(links, legacy_ids, model)
    update_policy_areas(links, legacy_ids, model)

    params = { previous_version: previous_version, links: links }
    API.patch_links(model.content_id, params)
  end

private

  def update_topics(links, legacy_ids, model)
    return unless model.respond_to?(:specialist_sector_tags)
    topics = API.get_linkables(document_type: 'topic')
      .to_a.map { |topic| topic["content_id"] } & legacy_ids

    links[:topics] += topics
    model.primary_specialist_sector_tag = topics.first
    model.secondary_specialist_sector_tags = topics.drop(1)
  end

  def update_policies(links, legacy_ids, model)
    return unless model.respond_to?(:policy_content_ids)
    policies = Policy.all.map(&:content_id) & legacy_ids
    links[:policies] += policies

    model.policy_content_ids = policies

    parent_policies = model.policy_content_ids - policies
    links[:policy_areas] += parent_policies
  end

  def update_policy_areas(links, legacy_ids, model)
    return unless model.respond_to?(:topics)
    model.topics = Topic.where(content_id: legacy_ids)
    links[:policy_areas] += model.topics.map(&:content_id)
  end

  def get_legacy_links(taxon_ids)
    API.get_links_for_content_ids(taxon_ids)
      .values.flat_map { |ls| ls["links"].fetch("legacy_taxons", []) }
  end

  def get_taxon_ids(model)
    response = API.get_links(model.content_id).to_h
    [response["version"], response["links"].fetch("taxons", [])]
  end

  def expand_parents(taxon_id)
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
