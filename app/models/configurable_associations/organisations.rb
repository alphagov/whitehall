module ConfigurableAssociations
  class Organisations
    def initialize(association, errors)
      @association = association
      @errors = errors
    end

    attr_reader :errors

    def links
      @association.includes(:organisation)
      primary_publishing_organisation = @association
                                          .select(&:lead?)
                                          .min_by(&:lead_ordering)
                                          &.organisation
      {
        organisations: @association.map { |edition_org| edition_org.organisation.content_id },
        primary_publishing_organisation: [primary_publishing_organisation&.content_id].compact,
      }
    end

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
