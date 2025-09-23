module ConfigurableAssociations
  class Organisations
    def initialize(association, errors)
      @association = association
      @errors = errors
    end

    attr_reader :errors

    def links
      @association.preload(:organisation)
      primary_publishing_organisation = @association
                                          .select { |edition_org| lead_organisation_selector(0, edition_org) }
                                          .first
                                          .organisation
      {
        organisations: @association.map { |edition_org| edition_org.organisation.content_id },
        primary_publishing_organisation: [primary_publishing_organisation.content_id],
      }
    end

    def selected_lead_organisation_id_at(lead_organisation_index)
      @association.select { |edition_org| lead_organisation_selector(lead_organisation_index, edition_org) }
                  .first.try(:organisation_id)
    end

    def selected_supporting_organisation_ids
      @association.reject(&:lead?).map(&:organisation_id)
    end

    def options_query
      Organisation.with_translations(:en).order("organisation_translations.name")
    end

    def to_partial_path
      "admin/configurable_associations/organisations"
    end

  private

    def lead_organisation_selector(lead_organisation_index, edition_org)
      edition_org.lead? && edition_org.lead_ordering == lead_organisation_index
    end
  end
end
