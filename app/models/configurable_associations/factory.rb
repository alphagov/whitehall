module ConfigurableAssociations
  class Factory
    def initialize(edition)
      @edition = edition
    end

    def configurable_associations
      @edition.type_instance.associations.map do |association_config|
        association = associations[association_config["key"]]
        raise "Undefined association: #{association_config['key']}" unless association

        association.call(@edition)
      end
    end

  private

    def associations
      {
        "ministerial_role_appointments" => ->(edition) { ConfigurableAssociations::MinisterialRoleAppointments.new(edition.role_appointments) },
        "topical_events" => ->(edition) { ConfigurableAssociations::TopicalEvents.new(edition.topical_events) },
      }.freeze
    end
  end
end
