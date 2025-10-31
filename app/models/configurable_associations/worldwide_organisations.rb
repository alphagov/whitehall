module ConfigurableAssociations
  class WorldwideOrganisations
    include Admin::TaggableContentHelper

    attr_reader :errors, :required

    def initialize(association, errors, required: false)
      @association = association
      @errors = errors
      @required = required
    end

    def links
      {
        worldwide_organisations: @association.map { |edition_worldwide_org| edition_worldwide_org.document.content_id },
      }
    end

    def options
      WorldwideOrganisation.includes(:document).latest_edition.order(:title).map do |worldwide_organisation|
        {
          text: worldwide_organisation.title,
          value: worldwide_organisation.document.id,
          selected: @association.map { |a| a.document.id }.include?(worldwide_organisation.document.id),
        }
      end
    end

    def to_partial_path
      "admin/configurable_associations/worldwide_organisations"
    end
  end
end
