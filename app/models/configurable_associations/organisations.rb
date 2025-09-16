module ConfigurableAssociations
  class Organisations
    def initialize(association, errors)
      @association = association
      @errors = errors
    end

    attr_reader :errors

    def selected_lead_organisation_id_at(lead_organisation_index)
      @association.select { |edition_org| lead_organisation_selector(lead_organisation_index, edition_org) }
                  .first.try(:organisation_id)
    end

    def selected_supporting_organisation_ids
      @association.where(lead: false).map(&:organisation_id)
    end

    def to_partial_path
      "admin/configurable_associations/organisations"
    end

  private

    def lead_organisation_selector(lead_organisation_index, edition_org)
      edition_org.lead? && edition_org.lead_ordering == lead_organisation_index + 1
    end
  end
end
