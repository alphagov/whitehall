module ConfigurableAssociations
  class WorldwideOrganisations
    include Admin::TaggableContentHelper

    def initialize(association, errors)
      @association = association
      @errors = errors
    end

    def links
      {
        worldwide_organisations: @association.map { |edition_worldwide_org| edition_worldwide_org.document.content_id },
      }
    end

    def options
      taggable_worldwide_organisations_container(@association)
    end

    def to_partial_path
      "admin/configurable_associations/worldwide_organisations"
    end
  end
end
