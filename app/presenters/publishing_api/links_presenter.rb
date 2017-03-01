module PublishingApi
  class LinksPresenter
    LINK_NAMES_TO_METHODS_MAP = {
      organisations: :organisation_ids,
      policy_areas: :policy_area_ids,
      related_policies: :related_policy_ids,
      policies: :policy_ids,
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

    def policy_area_ids
      (item.try(:topics) || []).map(&:content_id)
    end

    def related_policy_ids
      item.try(:policy_content_ids) || []
    end
    alias :policy_ids :related_policy_ids

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
      item.specialist_sectors.map(&:topic_content_id)
    end

    def parent_content_ids
      parent_content_id = item.primary_specialist_sectors.try(:first).try(:topic_content_id)
      parent_content_id ? [parent_content_id] : []
    end
  end
end
