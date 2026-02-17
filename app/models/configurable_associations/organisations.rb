module ConfigurableAssociations
  class Organisations
    def initialize(association, errors)
      @association = association
      @errors = errors
    end

    attr_reader :errors

    def selected_lead_organisation_id_at(lead_organisation_index)
      @association.select(&:lead?)
                  .sort_by(&:lead_ordering)[lead_organisation_index]
        &.organisation_id
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
  end
end
