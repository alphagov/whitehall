module ConfigurableAssociations
  class Factory
    def initialize(edition)
      @edition = edition
    end

    def configurable_associations(as_hash: false)
      result = {}
      @edition.type_instance.associations.each do |association_config|
        association = associations[association_config["key"]]
        raise "Undefined association: #{association_config['key']}" unless association

        result[association_config["key"]] = association.call(@edition)
      end

      as_hash ? result : result.values
    end

  private

    def associations
      {
        "ministerial_role_appointments" => ->(edition) { ConfigurableAssociations::MinisterialRoleAppointments.new(edition.role_appointments) },
        "topical_events" => ->(edition) { ConfigurableAssociations::TopicalEvents.new(edition.topical_events) },
        "world_locations" => ->(edition) { ConfigurableAssociations::WorldLocations.new(edition.world_locations, edition.errors, required: edition.world_location_association_required?) },
        "organisations" => ->(edition) { ConfigurableAssociations::Organisations.new(edition.edition_organisations, edition.errors) },
        "worldwide_organisations" => ->(edition) { ConfigurableAssociations::WorldwideOrganisations.new(edition.edition_worldwide_organisations, edition.errors, required: edition.worldwide_organisation_association_required?) },
      }.freeze
    end
  end
end
