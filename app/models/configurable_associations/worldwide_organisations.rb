module ConfigurableAssociations
  class WorldwideOrganisations
    def initialize(association, errors)
      @association = association
      @errors = errors
    end

    def links
      {
        worldwide_organisations: @association.map { |edition_worldwide_org| edition_worldwide_org.document.content_id },
      }
    end
  end
end
