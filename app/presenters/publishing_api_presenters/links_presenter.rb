module PublishingApiPresenters
  class LinksPresenter
    LINK_NAMES_TO_METHODS_MAP = {
      document_collections: :document_collection_ids,
      organisations: :organisation_ids,
      policy_areas: :policy_area_ids,
      related_policies: :related_policy_ids,
      statistical_data_set_documents: :statistical_data_set_ids,
      topics: :topic_content_ids,
      parent: :parent_content_ids,
      world_locations: :world_location_ids,
      worldwide_organisations: :worldwide_organisation_ids,
    }

    def initialize(item)
      @item = item
    end

    def extract(filter_links)
      filter_links.reduce(Hash.new) do |links, link_name|
        private_method_name = LINK_NAMES_TO_METHODS_MAP[link_name]
        links[link_name] = send(private_method_name)
        links
      end
    end

  private

    attr_reader :item

    def document_collection_ids
      (item.try(:published_document_collections) || []).map(&:content_id)
    end

    def policy_area_ids
      (item.try(:topics) || []).map(&:content_id)
    end

    def related_policy_ids
      item.try(:policy_content_ids) || []
    end

    def statistical_data_set_ids
      (item.try(:statistical_data_sets) || []).map(&:content_id)
    end

    def organisation_ids
      (item.try(:organisations) || []).map(&:content_id)
    end

    def world_location_ids
      (item.try(:world_locations) || []).map(&:content_id)
    end

    def worldwide_organisation_ids
      (item.try(:worldwide_organisations) || []).map(&:content_id)
    end

    def topic_content_ids
      return [] if topic_base_paths.blank?
      content_id_lookup.values
    end

    def parent_content_ids
      empty_parent = []
      return empty_parent if topic_base_paths.blank?
      parent_tag = item.primary_specialist_sector_tag
      return empty_parent if parent_tag.blank?

      parent_content_id = content_id_lookup[full_topic_path_from(parent_tag)]
      return [parent_content_id] if parent_content_id

      Rails.logger.info "#{item.content_id} has non-existing primary_specialist_sector_tag: #{parent_tag}"
      empty_parent
    end

    def topic_base_paths
      @topic_base_paths ||= item.specialist_sector_tags.map { |tag| full_topic_path_from(tag) }
    end

    def content_id_lookup
      @content_id_lookup ||= Whitehall.publishing_api_v2_client.lookup_content_ids(base_paths: topic_base_paths)
    end

    def full_topic_path_from(tag)
      "/topic/#{tag}"
    end
  end
end
