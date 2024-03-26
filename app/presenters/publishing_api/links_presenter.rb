module PublishingApi
  class LinksPresenter
    LINK_NAMES_TO_METHODS_MAP = {
      organisations: :organisation_ids,
      primary_publishing_organisation: :primary_publishing_organisation_id,
      original_primary_publishing_organisation: :original_primary_publishing_organisation_id,
      statistical_data_set_documents: :statistical_data_set_ids,
      world_locations: :world_location_ids,
      worldwide_organisations: :worldwide_organisation_ids,
      government: :government_id,
    }.freeze

    def initialize(item)
      @item = item
    end

    def extract(filter_links)
      if filter_links.include?(:organisations)
        filter_links << :primary_publishing_organisation
        filter_links << :original_primary_publishing_organisation
      end

      filter_links.each_with_object({}) do |link_name, links|
        private_method_name = LINK_NAMES_TO_METHODS_MAP[link_name]
        links[link_name] = send(private_method_name)
      end
    end

  private

    attr_reader :item

    def statistical_data_set_ids
      (item.try(:statistical_data_sets) || []).map(&:content_id)
    end

    def organisation_ids
      if item.try(:edition_organisations)
        item
          .try(:edition_organisations)
          .sort_by { |organisation| [organisation.lead_ordering ? 0 : 1, organisation.lead_ordering] }
          .map(&:organisation)
          .map(&:content_id)
      elsif item.try(:organisations)
        item
          .organisations
          .map(&:content_id)
      else
        []
      end
    end

    def primary_publishing_organisation_id
      lead_organisations = item.try(:lead_organisations) || []
      [lead_organisations.map(&:content_id).first].compact
    end

    def original_primary_publishing_organisation_id
      original_lead_organisations = item.try(:document).try(:editions).try(:first).try(:lead_organisations) || []
      [original_lead_organisations.map(&:content_id).first].compact
    end

    def world_location_ids
      (item.try(:world_locations) || []).map(&:content_id)
    end

    def worldwide_organisation_ids
      return (item.try(:editionable_worldwide_organisations) || []).map(&:content_id) if item.try(:editionable_worldwide_organisations)&.any?

      (item.try(:worldwide_organisations) || []).map(&:content_id)
    end

    def government_id
      [item.government&.content_id].compact
    end
  end
end
