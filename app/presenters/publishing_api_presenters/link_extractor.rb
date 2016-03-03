module PublishingApiPresenters
  class LinkExtractor
    LINK_NAMES_TO_METHODS_MAP = {
      document_collections: :document_collection_ids,
      lead_organisations: :lead_organisation_ids,
      organisations: :organisation_ids,
      policy_areas: :policy_area_ids,
      related_policies: :related_policy_ids,
      statistical_data_set_documents: :statistical_data_set_ids,
      supporting_organisations: :supporting_organisation_ids,
      topics: :topic_content_ids,
      world_locations: :world_location_ids,
      worldwide_organisations: :worldwide_organisation_ids,
      worldwide_priorities: :worldwide_priority_ids,
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

    def lead_organisation_ids
      (item.try(:lead_organisations) || []).map(&:content_id)
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

    def supporting_organisation_ids
      (item.try(:supporting_organisations) || []).map(&:content_id)
    end

    def organisation_ids
      (item.try(:organisations) || []).map(&:content_id)
    end

    def topic_content_ids
      secondaries = item.try(:secondary_specialist_sector_tags) || []
      primary = item.try(:primary_specialist_sector_tag)
      (secondaries.unshift(primary))
        .compact
        .map do |tag|
          Whitehall.content_store.content_item!("/topic/#{tag}").content_id
        end
    end

    def world_location_ids
      (item.try(:world_locations) || []).map(&:content_id)
    end

    def worldwide_organisation_ids
      (item.try(:worldwide_organisations) || []).map(&:content_id)
    end

    # FIXME: these tags will be discontinued
    def worldwide_priority_ids
      (item.try(:worldwide_priorities) || []).map(&:content_id)
    end
  end
end
